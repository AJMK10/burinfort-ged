"""
OpenClaw Skill — Veille Marchés Publics Côte d'Ivoire (v2)
===========================================================
Scrape les portails ivoiriens, enrichit via IA, archive l'historique.

Sources :
  ARCOP (arcop.ci), DGMP-DSP (marchespublics.ci),
  ARTCI (artci.ci), ANADER (anader.ci)

Variables d'environnement :
  ALFRESCO_URL       http://alfresco:8080/alfresco
  ALFRESCO_USER      admin
  ALFRESCO_PASS      admin
  CI_ROWS            30
  ANTHROPIC_API_KEY  clé API Anthropic (résumés IA)
  SMTP_HOST          serveur SMTP pour alertes email
  SMTP_PORT          587
  SMTP_USER          compte SMTP
  SMTP_PASS          mot de passe SMTP
  ALERT_TO           destinataire(s) séparés par virgule
  ALERT_FROM         expéditeur (défaut = SMTP_USER)
"""

import os
import sys
import io
import json
import datetime
import base64
import smtplib
import urllib.request
import urllib.parse
import urllib.error
import re
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Force UTF-8 sur Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

try:
    from bs4 import BeautifulSoup
    BS4_AVAILABLE = True
except ImportError:
    BS4_AVAILABLE = False
    print("[WARN] BeautifulSoup4 non disponible — scraping limité")

try:
    from pdfminer.high_level import extract_text as pdf_extract_text
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False

# ── Configuration ────────────────────────────────────────────────────────────
ALFRESCO_URL  = os.environ.get("ALFRESCO_URL",  "http://alfresco:8080/alfresco")
ALFRESCO_USER = os.environ.get("ALFRESCO_USER", "admin")
ALFRESCO_PASS = os.environ.get("ALFRESCO_PASS", "admin")
CI_ROWS       = int(os.environ.get("CI_ROWS", "30"))

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")

SMTP_HOST  = os.environ.get("SMTP_HOST", "")
SMTP_PORT  = int(os.environ.get("SMTP_PORT", "587"))
SMTP_USER  = os.environ.get("SMTP_USER", "")
SMTP_PASS  = os.environ.get("SMTP_PASS", "")
ALERT_TO   = os.environ.get("ALERT_TO", "")
ALERT_FROM = os.environ.get("ALERT_FROM", "") or SMTP_USER

CACHE_PATH = "/Veille"
CACHE_FILE = "marches-ci-cache.json"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; BURINFORT-GED-Bot/1.0)",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "fr-FR,fr;q=0.9",
}

IT_FILTER = re.compile(
    r"informatique|logiciel|num[eé]rique|syst[eè]me.d.information|"
    r"\bGED\b|\bSIG\b|\bSI\b|\bDSI\b|\bIT\b|"
    r"r[eé]seau|t[eé]l[eé]com|t[eé]l[eé]phonie|"
    r"d[eé]veloppement.*(web|mobile|application)|"
    r"serveur|infrastructure|cloud|cyber|s[eé]curit[eé].*inform|"
    r"base.de.donn[eé]e|data.?base|progiciel|ERP|CRM|"
    r"maintenance.*informatique|prestation.*informatique|"
    r"mat[eé]riel.*informatique|[eé]quipement.*informatique|"
    r"ordinateur|imprimante|scanner|r[eé]seau.local|wifi|"
    r"audit.*(informatique|SI)|consulting.*(IT|num[eé]rique)",
    re.IGNORECASE
)

def is_it_related(titre: str) -> bool:
    return bool(IT_FILTER.search(titre))

# ── HTTP helpers ─────────────────────────────────────────────────────────────

def _get(url: str, timeout: int = 20, binary: bool = False):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        data = r.read()
    if binary:
        return data
    charset = "utf-8"
    ct = r.headers.get("Content-Type", "") if hasattr(r, "headers") else ""
    m = re.search(r"charset=([^\s;]+)", ct)
    if m:
        charset = m.group(1)
    return data.decode(charset, errors="replace")


_NAV_AO_RE = re.compile(
    r"appel.?d?.offre|avis.?(appel|march[eé]|attribution|infructueux)|"
    r"dossier.appel|offre.march[eé]|consultation|ann[oô]nce|"
    r"publication|avis.march[eé]|appel.d.offre|offres",
    re.IGNORECASE
)

_ITEM_AO_RE = re.compile(
    r"appel|offre|avis|march[eé]|dossier|prestation|fourniture|travaux|"
    r"acquisition|recrutement.*consultant|service",
    re.IGNORECASE
)


def _abs(href: str, base: str) -> str:
    if href.startswith("http"):
        return href
    if href.startswith("//"):
        return "https:" + href
    base = base.rstrip("/")
    return base + ("" if href.startswith("/") else "/") + href.lstrip("/")


def _find_listing_urls(html: str, base: str) -> list:
    if not BS4_AVAILABLE:
        return []
    soup = BeautifulSoup(html, "html.parser")
    seen, results = set(), []
    for a in soup.find_all("a", href=True):
        href = a["href"].strip()
        if not href or href.startswith("#") or href.startswith("mailto:"):
            continue
        text = a.get_text(" ", strip=True)
        if _NAV_AO_RE.search(text) or _NAV_AO_RE.search(href):
            full = _abs(href, base)
            if full != base and full not in seen:
                seen.add(full)
                results.append(full)
    return results


def _extract_items(html: str, base: str, source: str, max_rows: int) -> list:
    items = []
    if not BS4_AVAILABLE:
        return items
    soup = BeautifulSoup(html, "html.parser")
    today_str = datetime.date.today().strftime("%d/%m/%Y")

    def make_item(titre, acheteur, dp, dl, url, ref=""):
        titre = " ".join(titre.split())
        if len(titre) < 10:
            return None
        return {
            "source":          source,
            "titre":           titre,
            "acheteur":        " ".join(acheteur.split()),
            "datePublication": dp or today_str,
            "dateLimite":      dl or "",
            "budget":          "",
            "urlAvis":         url or base,
            "reference":       ref,
            "aiSummary":       "",
            "aiScore":         0,
            "aiPoints":        [],
            "firstSeen":       datetime.datetime.now().strftime("%Y-%m-%d %H:%M"),
            "isArchived":      False,
        }

    best_table, best_count = None, 0
    for tbl in soup.find_all("table"):
        rows = tbl.find_all("tr")
        if len(rows) > best_count:
            best_count = len(rows)
            best_table = tbl

    if best_table and best_count > 2:
        rows = best_table.find_all("tr")[1:]
        for row in rows[:max_rows]:
            cells = [c.get_text(" ", strip=True) for c in row.find_all(["td", "th"])]
            if len(cells) < 2:
                continue
            link = row.find("a", href=True)
            href = _abs(link["href"], base) if link else base
            titre = link.get_text(strip=True) if link else cells[0]
            it = make_item(
                titre or cells[0],
                cells[1] if len(cells) > 1 else "",
                cells[2] if len(cells) > 2 else "",
                cells[3] if len(cells) > 3 else "",
                href
            )
            if it:
                items.append(it)
        if items:
            return items

    for sel in [
        "article", "div.item", "div.entry", "div.post", "div.tender",
        "div.avis", "div.ao", "li.item", "li.avis", "li.ao",
    ]:
        blocks = soup.select(sel)
        if len(blocks) < 2:
            continue
        for blk in blocks[:max_rows]:
            link = blk.find("a", href=True)
            if not link:
                continue
            text = link.get_text(" ", strip=True)
            if not _ITEM_AO_RE.search(text):
                continue
            href = _abs(link["href"], base)
            date_m = re.search(r"\b(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}-\d{2}-\d{2})\b",
                               blk.get_text())
            dp = date_m.group(0) if date_m else ""
            it = make_item(text, "", dp, "", href)
            if it:
                items.append(it)
        if items:
            return items

    seen_hrefs = set()
    for a in soup.find_all("a", href=True):
        text = a.get_text(" ", strip=True)
        href = a["href"].strip()
        if len(text) < 15 or href.startswith("#") or href.startswith("mailto:"):
            continue
        if not _ITEM_AO_RE.search(text) and not _ITEM_AO_RE.search(href):
            continue
        full = _abs(href, base)
        if full in seen_hrefs:
            continue
        seen_hrefs.add(full)
        it = make_item(text, "", "", "", full)
        if it:
            items.append(it)
        if len(items) >= max_rows:
            break

    return items


def _scrape_site(label: str, home: str, source: str, max_rows: int) -> list:
    try:
        home_html = _get(home)
        print(f"  [OK] {label} : page d'accueil chargee ({home})")
    except Exception as e:
        print(f"  ✗ {label} : {home} — {e}")
        return []

    listing_urls = _find_listing_urls(home_html, home)
    if listing_urls:
        print(f"  → {label} : {len(listing_urls)} lien(s) de listing trouvé(s) : {listing_urls[:3]}")
    else:
        print(f"  → {label} : aucun lien de listing dans la nav — extraction depuis l'accueil")

    pages_to_try = (listing_urls[:3] or [home])
    all_items = []
    for url in pages_to_try:
        try:
            html = _get(url) if url != home else home_html
            items = _extract_items(html, url, source, max_rows)
            print(f"  → {label} ({url}) : {len(items)} élément(s) extrait(s)")
            all_items.extend(items)
            if len(all_items) >= max_rows:
                break
        except Exception as e:
            print(f"  ✗ {label} ({url}) — {e}")

    seen, unique = set(), []
    for it in all_items:
        k = it["urlAvis"]
        if k not in seen:
            seen.add(k)
            unique.append(it)
    return unique[:max_rows]

# ── Scrapers par source ───────────────────────────────────────────────────────

def scrape_marchespublics_ci(max_rows: int) -> list:
    items = _scrape_site("DGMP-DSP", "https://www.marchespublics.ci/", "DGMP-DSP", max_rows)
    if len(items) < 5:
        for url in [
            "https://www.marchespublics.ci/index.php/avis-appel-offres",
            "https://www.marchespublics.ci/index.php/appels-offres",
            "https://www.marchespublics.ci/publication/avis",
            "https://simp.gouv.ci/avis-appel-offres",
            "https://www.simp.gouv.ci/",
        ]:
            try:
                html  = _get(url)
                extra = _extract_items(html, url, "DGMP-DSP", max_rows - len(items))
                print(f"  → DGMP-DSP ({url}) : {len(extra)} élément(s)")
                items.extend(extra)
                if len(items) >= max_rows:
                    break
            except Exception as e:
                print(f"  ✗ DGMP-DSP ({url}) — {e}")
    return items[:max_rows]


def scrape_anrmp_ci(max_rows: int) -> list:
    items = _scrape_site("ARCOP", "https://arcop.ci/", "ARCOP", max_rows)
    if len(items) < 5:
        items.extend(_scrape_site("ANRMP", "https://www.anrmp.ci/", "ANRMP",
                                  max_rows - len(items)))
    return items[:max_rows]


def scrape_artci(max_rows: int) -> list:
    try:
        return _scrape_site("ARTCI", "https://www.artci.ci/", "ARTCI", max_rows)
    except Exception as e:
        print(f"  ✗ ARTCI inaccessible : {e}")
        return []


def scrape_anader(max_rows: int) -> list:
    try:
        return _scrape_site("ANADER", "https://www.anader.ci/", "ANADER", max_rows)
    except Exception as e:
        print(f"  ✗ ANADER inaccessible : {e}")
        return []

# ── Extraction PDF ────────────────────────────────────────────────────────────

_PDF_DATE_RE    = re.compile(
    r"(?:date\s+limite|d[eé]p[oô]t.*?offres?)[^\n]*?(\d{2}[/.\-]\d{2}[/.\-]\d{4})",
    re.IGNORECASE
)
_PDF_BUDGET_RE  = re.compile(
    r"(?:montant|budget|pr[eé]vision)[^\n]*?(\d[\d\s]{2,}(?:000|millions?|FCFA|XOF))",
    re.IGNORECASE
)
_PDF_ACHETEUR_RE = re.compile(
    r"(?:autorit[eé]\s+contractante|ma[iî]tre\s+d.ouvrage)[^\n]*\n([^\n]{5,80})",
    re.IGNORECASE
)


def enrich_from_pdf(item: dict) -> None:
    """Télécharge le PDF et enrichit l'item avec date_limite, budget, acheteur."""
    url = item.get("urlAvis", "")
    if not url or not re.search(r"\.pdf($|\?)", url, re.IGNORECASE):
        return
    if not PDF_AVAILABLE:
        return
    try:
        pdf_bytes = _get(url, timeout=30, binary=True)
        text = pdf_extract_text(io.BytesIO(pdf_bytes))
        item["_pdfText"] = text[:8000]  # tronquer pour l'IA

        if not item.get("dateLimite"):
            m = _PDF_DATE_RE.search(text)
            if m:
                item["dateLimite"] = m.group(1)

        if not item.get("budget"):
            m = _PDF_BUDGET_RE.search(text)
            if m:
                item["budget"] = m.group(1).strip()

        if not item.get("acheteur") or re.match(r"^\d+$", item.get("acheteur", "")):
            m = _PDF_ACHETEUR_RE.search(text)
            if m:
                item["acheteur"] = m.group(1).strip()

        print(f"    ↳ PDF enrichi : dl={item.get('dateLimite','')} budget={item.get('budget','')[:40]}")
    except Exception as e:
        print(f"    ↳ PDF non extrait ({url[:60]}) : {e}")

# ── Résumé IA (Anthropic) ─────────────────────────────────────────────────────

def generate_ai_summary(titre: str, pdf_text: str = "") -> dict | None:
    if not ANTHROPIC_API_KEY:
        return None
    try:
        import urllib.request as ur
        context = f"Titre : {titre}"
        if pdf_text:
            context += f"\n\nExtrait PDF :\n{pdf_text[:3000]}"
        prompt = (
            "Tu es un assistant spécialisé en marchés publics ivoiriens. "
            "Analyse cet appel d'offres et réponds UNIQUEMENT avec un objet JSON valide "
            "(pas de texte avant ou après) avec ces clés :\n"
            '- "resume" : 2 phrases en français résumant l\'objet et l\'enjeu\n'
            '- "score" : entier 0-100 indiquant la pertinence pour une société ivoirienne '
            "spécialisée en GED, systèmes d'information, et numérique\n"
            '- "points_cles" : liste de 2-3 points clés courts\n'
            '- "date_limite" : date limite de dépôt au format DD/MM/YYYY si trouvée, sinon ""\n'
            '- "budget" : montant estimé si trouvé, sinon ""\n\n'
            f"{context}"
        )
        body = json.dumps({
            "model": "claude-haiku-4-5",
            "max_tokens": 400,
            "messages": [{"role": "user", "content": prompt}]
        }).encode()
        req = ur.Request(
            "https://api.anthropic.com/v1/messages",
            data=body,
            headers={
                "x-api-key": ANTHROPIC_API_KEY,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            method="POST"
        )
        with ur.urlopen(req, timeout=30) as r:
            resp = json.loads(r.read())
        text = resp["content"][0]["text"]
        m = re.search(r"\{.*\}", text, re.DOTALL)
        if m:
            return json.loads(m.group(0))
    except Exception as e:
        # Fallback modèle alternatif
        if "model" in str(e).lower() or "not_found" in str(e).lower():
            try:
                body2 = json.dumps({
                    "model": "claude-3-5-haiku-20241022",
                    "max_tokens": 400,
                    "messages": [{"role": "user", "content": prompt}]
                }).encode()
                req2 = urllib.request.Request(
                    "https://api.anthropic.com/v1/messages",
                    data=body2,
                    headers={
                        "x-api-key": ANTHROPIC_API_KEY,
                        "anthropic-version": "2023-06-01",
                        "content-type": "application/json",
                    },
                    method="POST"
                )
                with urllib.request.urlopen(req2, timeout=30) as r:
                    resp = json.loads(r.read())
                text = resp["content"][0]["text"]
                m = re.search(r"\{.*\}", text, re.DOTALL)
                if m:
                    return json.loads(m.group(0))
            except Exception:
                pass
        print(f"    ↳ IA non disponible : {e}")
    return None

# ── Historique ────────────────────────────────────────────────────────────────

def load_existing_cache() -> dict:
    """Charge le cache JSON existant depuis Alfresco."""
    headers = {**_auth_header(), "Accept": "application/json"}
    # Chercher le fichier
    try:
        folder_id = _ensure_folder(CACHE_PATH)
        if not folder_id:
            return {"items": []}
        file_id = _get_or_create_file_id(folder_id, CACHE_FILE)
        if not file_id:
            return {"items": []}
        url = (f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1"
               f"/nodes/{file_id}/content")
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as r:
            return json.loads(r.read())
    except Exception:
        return {"items": []}


def merge_with_history(existing: dict, new_items: list, ttl_days: int = 30) -> list:
    """Fusionne les nouveaux items avec l'historique, archive les disparus."""
    existing_items = existing.get("items", [])
    existing_by_url = {it.get("urlAvis", ""): it for it in existing_items if it.get("urlAvis")}
    new_urls = {it.get("urlAvis", "") for it in new_items}
    cutoff = datetime.datetime.now() - datetime.timedelta(days=ttl_days)

    merged = []
    for it in new_items:
        url = it.get("urlAvis", "")
        if url in existing_by_url:
            old = existing_by_url[url]
            # Conserver les données enrichies
            it["firstSeen"]  = old.get("firstSeen", it["firstSeen"])
            it["aiSummary"]  = it.get("aiSummary") or old.get("aiSummary", "")
            it["aiScore"]    = it.get("aiScore") or old.get("aiScore", 0)
            it["aiPoints"]   = it.get("aiPoints") or old.get("aiPoints", [])
            it["dateLimite"] = it.get("dateLimite") or old.get("dateLimite", "")
            it["budget"]     = it.get("budget") or old.get("budget", "")
            if not it.get("acheteur") or re.match(r"^\d+$", it.get("acheteur", "")):
                it["acheteur"] = old.get("acheteur", it.get("acheteur", ""))
        it["isArchived"] = False
        merged.append(it)

    # Ajouter les items archivés (disparus du site mais récents)
    for url, old in existing_by_url.items():
        if url not in new_urls:
            try:
                first_seen = datetime.datetime.strptime(
                    old.get("firstSeen", "2000-01-01 00:00"), "%Y-%m-%d %H:%M"
                )
            except ValueError:
                first_seen = datetime.datetime(2000, 1, 1)
            if first_seen > cutoff:
                old["isArchived"] = True
                merged.append(old)

    merged.sort(key=lambda x: x.get("firstSeen", ""), reverse=True)
    return merged

# ── Email d'alerte ────────────────────────────────────────────────────────────

def send_alert_email(new_items: list) -> None:
    if not SMTP_HOST or not ALERT_TO:
        return
    try:
        subject = f"[BURINFORT GED] {len(new_items)} nouveau(x) AO informatique(s) — Côte d'Ivoire"
        lines = [
            f"<h2>{len(new_items)} nouvel(s) appel(s) d'offres IT — Côte d'Ivoire</h2>",
            "<ul>",
        ]
        for it in new_items:
            score_html = f" <b>[score: {it['aiScore']}/100]</b>" if it.get("aiScore") else ""
            src = it.get("source", "")
            titre = it.get("titre", "")[:100]
            url = it.get("urlAvis", "")
            dl = it.get("dateLimite", "")
            dl_html = f" — Date limite : <b>{dl}</b>" if dl else ""
            summary = it.get("aiSummary", "")
            lines.append(
                f'<li><b>[{src}]</b>{score_html} '
                f'<a href="{url}">{titre}</a>{dl_html}'
                + (f"<br><i>{summary}</i>" if summary else "")
                + "</li>"
            )
        lines.append("</ul>")
        lines.append("<hr><small>Généré par BURINFORT GED — Veille marchés publics CI</small>")
        body_html = "\n".join(lines)

        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"]    = ALERT_FROM
        msg["To"]      = ALERT_TO
        msg.attach(MIMEText(body_html, "html", "utf-8"))

        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as srv:
            srv.ehlo()
            srv.starttls()
            if SMTP_USER:
                srv.login(SMTP_USER, SMTP_PASS)
            srv.sendmail(ALERT_FROM, [a.strip() for a in ALERT_TO.split(",")], msg.as_string())
        print(f"  ✉ Alerte email envoyée à {ALERT_TO}")
    except Exception as e:
        print(f"  ✗ Email non envoyé : {e}")

# ── Alfresco helpers ──────────────────────────────────────────────────────────

def _auth_header() -> dict:
    token = base64.b64encode(f"{ALFRESCO_USER}:{ALFRESCO_PASS}".encode()).decode()
    return {"Authorization": f"Basic {token}"}


def _ensure_folder(path: str) -> str | None:
    headers = {**_auth_header(), "Accept": "application/json", "Content-Type": "application/json"}
    parts  = [p for p in path.strip("/").split("/") if p]
    parent = "-root-"
    for part in parts:
        q   = urllib.parse.quote(part)
        url = (f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1"
               f"/nodes/{parent}/children?where=(isFolder=true)&name={q}")
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=10) as r:
                data    = json.loads(r.read())
                entries = data.get("list", {}).get("entries", [])
                match   = next((e["entry"] for e in entries if e["entry"]["name"] == part), None)
                if match:
                    parent = match["id"]
                    continue
        except Exception:
            pass
        payload = json.dumps({"name": part, "nodeType": "cm:folder"}).encode()
        req2 = urllib.request.Request(
            f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1/nodes/{parent}/children",
            data=payload, headers=headers, method="POST"
        )
        try:
            with urllib.request.urlopen(req2, timeout=10) as r:
                data   = json.loads(r.read())
                parent = data["entry"]["id"]
        except Exception as e:
            print(f"  ✗ Impossible de créer le dossier '{part}' : {e}")
            return None
    return parent


def _get_or_create_file_id(folder_id: str, filename: str) -> str | None:
    headers = {**_auth_header(), "Accept": "application/json"}
    q   = urllib.parse.quote(filename)
    url = (f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1"
           f"/nodes/{folder_id}/children?name={q}")
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as r:
            data    = json.loads(r.read())
            entries = data.get("list", {}).get("entries", [])
            match   = next((e["entry"] for e in entries if e["entry"]["name"] == filename), None)
            if match:
                return match["id"]
    except Exception:
        pass
    return None


def _upload_or_update(folder_id: str, filename: str, content: bytes) -> bool:
    headers = {**_auth_header(), "Accept": "application/json"}
    existing_id = _get_or_create_file_id(folder_id, filename)

    if existing_id:
        url = (f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1"
               f"/nodes/{existing_id}/content?name={urllib.parse.quote(filename)}")
        req = urllib.request.Request(
            url, data=content,
            headers={**headers, "Content-Type": "application/json"},
            method="PUT"
        )
        try:
            with urllib.request.urlopen(req, timeout=15):
                return True
        except Exception as e:
            print(f"  ✗ Mise à jour échouée : {e}")
            return False
    else:
        boundary = "BURI_BOUNDARY_CI"
        body = (
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="filedata"; filename="{filename}"\r\n'
            f"Content-Type: application/json\r\n\r\n"
        ).encode() + content + f"\r\n--{boundary}--\r\n".encode()
        url = (f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1"
               f"/nodes/{folder_id}/children")
        req = urllib.request.Request(
            url, data=body,
            headers={**headers, "Content-Type": f"multipart/form-data; boundary={boundary}"},
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, timeout=15) as r:
                return r.status == 201
        except Exception as e:
            print(f"  ✗ Création échouée : {e}")
            return False

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    print(f"[{now}] Veille Marchés Publics Informatique — Côte d'Ivoire")
    print()

    # 1. Charger l'historique existant
    print("  Chargement de l'historique...")
    existing = load_existing_cache()
    print(f"  → {len(existing.get('items', []))} item(s) en cache")

    # 2. Scraper toutes les sources
    raw = []
    raw.extend(scrape_marchespublics_ci(CI_ROWS))
    raw.extend(scrape_anrmp_ci(CI_ROWS // 2))
    raw.extend(scrape_artci(CI_ROWS // 4))
    raw.extend(scrape_anader(CI_ROWS // 4))

    # 3. Filtrer IT + anti-européen
    items = [
        it for it in raw
        if is_it_related(it.get("titre", ""))
        and "europ" not in it.get("titre", "").lower()
        and "europ" not in it.get("source", "").lower()
    ]

    # 4. Identifier les nouveaux
    existing_urls = {it.get("urlAvis", "") for it in existing.get("items", [])}
    new_items = [it for it in items if it.get("urlAvis", "") not in existing_urls]
    print(f"\n  → {len(raw)} avis bruts → {len(items)} après filtre IT, {len(new_items)} nouveau(x)")

    # 5. Enrichissement PDF des nouveaux
    if new_items and PDF_AVAILABLE:
        print(f"\n  Extraction PDF ({len(new_items)} nouveau(x))...")
        for it in new_items:
            enrich_from_pdf(it)

    # 6. Résumé IA pour les nouveaux
    if new_items and ANTHROPIC_API_KEY:
        print(f"\n  Résumés IA ({len(new_items)} nouveau(x))...")
        for it in new_items:
            ai = generate_ai_summary(it.get("titre", ""), it.get("_pdfText", ""))
            if ai:
                it["aiSummary"]  = ai.get("resume", "")
                it["aiScore"]    = int(ai.get("score", 0))
                it["aiPoints"]   = ai.get("points_cles", [])
                if ai.get("date_limite") and not it.get("dateLimite"):
                    it["dateLimite"] = ai["date_limite"]
                if ai.get("budget") and not it.get("budget"):
                    it["budget"] = ai["budget"]
                print(f"    ↳ [{it['source']}] score={it['aiScore']} — {it['titre'][:50]}")
            it.pop("_pdfText", None)

    # 7. Fusionner avec historique
    merged = merge_with_history(existing, items)
    archived_count = len([i for i in merged if i.get("isArchived")])

    # 8. Alertes email
    if new_items:
        send_alert_email(new_items)

    # 9. Afficher résumé
    print(f"\n  → {len(items)} actifs, {len(new_items)} nouveau(x), {archived_count} archivé(s)")
    print()
    for ao in items[:10]:
        score = f" [score:{ao.get('aiScore',0)}]" if ao.get("aiScore") else ""
        dl    = f" — dl:{ao.get('dateLimite','')}" if ao.get("dateLimite") else ""
        print(f"  • [{ao['source']}]{score} {ao['titre'][:70]}{dl}")
        if ao.get("urlAvis"):
            print(f"    {ao['urlAvis']}")

    # 10. Sauvegarder dans Alfresco
    if not merged:
        print("  Aucun résultat — cache non mis à jour.")
        return

    payload = {
        "generatedAt": now,
        "total": len([i for i in merged if not i.get("isArchived")]),
        "items": merged,
    }
    content = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")

    folder_id = _ensure_folder(CACHE_PATH)
    if not folder_id:
        print("  ✗ Dossier Alfresco inaccessible — cache non sauvegardé.")
        return

    ok = _upload_or_update(folder_id, CACHE_FILE, content)
    if ok:
        print(f"\n  ✓ Cache mis à jour : {CACHE_PATH}/{CACHE_FILE}")
    else:
        print(f"\n  ✗ Échec de la sauvegarde dans Alfresco.")


if __name__ == "__main__":
    main()
