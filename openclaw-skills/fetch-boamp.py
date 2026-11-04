"""
OpenClaw Skill — Veille Appels d'offres BOAMP
==============================================
Ce script récupère les appels d'offres IT/DSI depuis l'API BOAMP OpenDataSoft
et peut les archiver dans Alfresco GED.

Usage via OpenClaw :
  "Fetche les nouveaux appels d'offres informatique et archive-les dans Alfresco"

Configuration :
  ALFRESCO_URL  = URL de base Alfresco  (ex: http://localhost:8085/alfresco)
  ALFRESCO_USER = Utilisateur Alfresco   (défaut: admin)
  ALFRESCO_PASS = Mot de passe Alfresco  (défaut: admin)
  BOAMP_KEYWORDS = Mots-clés de recherche (séparés par des espaces)
  BOAMP_ROWS     = Nombre de résultats   (défaut: 20)
"""

import os
import json
import datetime
import urllib.request
import urllib.parse

# --- Configuration -----------------------------------------------------------
ALFRESCO_URL  = os.environ.get("ALFRESCO_URL",  "http://localhost:8085/alfresco")
ALFRESCO_USER = os.environ.get("ALFRESCO_USER", "admin")
ALFRESCO_PASS = os.environ.get("ALFRESCO_PASS", "admin")
BOAMP_KEYWORDS = os.environ.get("BOAMP_KEYWORDS",
    'informatique OR logiciel OR "système information" OR numérique OR GED')
BOAMP_ROWS     = int(os.environ.get("BOAMP_ROWS", "20"))

BOAMP_API = "https://boamp-datadila.opendatasoft.com/api/records/1.0/search/"
ALFRESCO_FOLDER_PATH = "/Company Home/Veille/Appels d'offres"

# --- Fonctions ---------------------------------------------------------------

def fetch_boamp(keywords: str, rows: int) -> dict:
    """Appelle l'API BOAMP et retourne les résultats."""
    params = urllib.parse.urlencode({
        "dataset": "boamp",
        "q":       keywords,
        "rows":    rows,
        "sort":    "-dateparution",
        "refine.nature": "APPEL_OFFRE",
    })
    url = BOAMP_API + "?" + params
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        return json.loads(resp.read().decode("utf-8"))


def normalize_ao(record: dict) -> dict:
    """Normalise un enregistrement BOAMP en objet simple."""
    f = record.get("fields", {})
    dl = f.get("datelimitereponse", "")
    return {
        "id":           f.get("id", record.get("recordid", "")),
        "objet":        f.get("objet", ""),
        "acheteur":     f.get("nomacheteur", ""),
        "dateParution": f.get("dateparution", ""),
        "dateLimite":   dl[:10] if dl else "",
        "url":          f.get("url_avis", ""),
        "typeMarche":   f.get("type_marche_facette", ""),
        "procedure":    f.get("procedure_libelle", ""),
        "perimetre":    f.get("famille_libelle", ""),
    }


def get_alfresco_folder_id(folder_path: str):
    """Résout un chemin Alfresco et retourne le nodeId du dossier."""
    import base64
    encoded = base64.b64encode(f"{ALFRESCO_USER}:{ALFRESCO_PASS}".encode()).decode()
    # Résolution via path query
    path_encoded = urllib.parse.quote(folder_path, safe="")
    url = f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1/nodes/-root-/children?relativePath={path_encoded}"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Basic {encoded}",
        "Accept": "application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            # Récupère le nodeId du dossier parent via relativePath sur -root-
            pass
        # Approche alternative: GET /nodes/-root-?relativePath=...
        url2 = f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1/nodes/-root-?relativePath={path_encoded}"
        req2 = urllib.request.Request(url2, headers={
            "Authorization": f"Basic {encoded}",
            "Accept": "application/json",
        })
        with urllib.request.urlopen(req2, timeout=10) as resp2:
            data = json.loads(resp2.read().decode("utf-8"))
            return data["entry"]["id"]
    except Exception as e:
        print(f"  ⚠ Impossible de résoudre le dossier '{folder_path}' : {e}")
        return None


def ensure_folder(path: str):
    """Crée le dossier Alfresco si inexistant, retourne le nodeId."""
    import base64
    encoded = base64.b64encode(f"{ALFRESCO_USER}:{ALFRESCO_PASS}".encode()).decode()
    headers = {
        "Authorization": f"Basic {encoded}",
        "Accept": "application/json",
        "Content-Type": "application/json",
    }

    parts   = [p for p in path.strip("/").split("/") if p]
    parent  = "-root-"
    for part in parts:
        q = urllib.parse.quote(part)
        url = f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1/nodes/{parent}/children?where=(isFolder=true)&name={q}"
        req = urllib.request.Request(url, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                data  = json.loads(resp.read().decode("utf-8"))
                items = data.get("list", {}).get("entries", [])
                match = next((e["entry"] for e in items if e["entry"]["name"] == part), None)
                if match:
                    parent = match["id"]
                    continue
        except Exception:
            pass
        # Créer le dossier
        payload = json.dumps({"name": part, "nodeType": "cm:folder"}).encode("utf-8")
        create_req = urllib.request.Request(
            f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1/nodes/{parent}/children",
            data=payload, headers=headers, method="POST"
        )
        try:
            with urllib.request.urlopen(create_req, timeout=10) as resp:
                data   = json.loads(resp.read().decode("utf-8"))
                parent = data["entry"]["id"]
        except Exception as e:
            print(f"  ⚠ Impossible de créer le dossier '{part}' : {e}")
            return None
    return parent


def archive_ao_in_alfresco(ao: dict, folder_id: str) -> bool:
    """Crée un document JSON dans Alfresco pour un appel d'offres."""
    import base64
    encoded  = base64.b64encode(f"{ALFRESCO_USER}:{ALFRESCO_PASS}".encode()).decode()
    filename = f"AO_{ao['id']}_{ao['dateParution']}.json"
    content  = json.dumps(ao, ensure_ascii=False, indent=2).encode("utf-8")

    # Vérifier si le document existe déjà
    search_url = (f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1/nodes/{folder_id}"
                  f"/children?name={urllib.parse.quote(filename)}")
    check_req = urllib.request.Request(search_url, headers={
        "Authorization": f"Basic {encoded}", "Accept": "application/json"
    })
    try:
        with urllib.request.urlopen(check_req, timeout=10) as resp:
            data  = json.loads(resp.read().decode("utf-8"))
            items = data.get("list", {}).get("entries", [])
            if any(e["entry"]["name"] == filename for e in items):
                return False  # déjà archivé
    except Exception:
        pass

    # Créer le document via multipart
    boundary = "----AO_BOUNDARY"
    body = (
        f"------AO_BOUNDARY\r\n"
        f'Content-Disposition: form-data; name="filedata"; filename="{filename}"\r\n'
        f"Content-Type: application/json\r\n\r\n"
    ).encode("utf-8") + content + f"\r\n------AO_BOUNDARY--\r\n".encode("utf-8")

    upload_url = f"{ALFRESCO_URL}/api/-default-/public/alfresco/versions/1/nodes/{folder_id}/children"
    upload_req = urllib.request.Request(upload_url, data=body, headers={
        "Authorization": f"Basic {encoded}",
        "Content-Type": f"multipart/form-data; boundary=----AO_BOUNDARY",
    }, method="POST")
    try:
        with urllib.request.urlopen(upload_req, timeout=15) as resp:
            return resp.status == 201
    except Exception as e:
        print(f"  ⚠ Impossible d'archiver '{filename}' : {e}")
        return False


# --- Main --------------------------------------------------------------------

def main():
    print(f"[{datetime.datetime.now():%Y-%m-%d %H:%M}] Veille BOAMP — {BOAMP_KEYWORDS!r}")
    print()

    # 1. Récupérer les AO depuis BOAMP
    try:
        raw   = fetch_boamp(BOAMP_KEYWORDS, BOAMP_ROWS)
        total = raw.get("nhits", 0)
        items = [normalize_ao(r) for r in raw.get("records", [])]
        print(f"  ✓ {total} appels d'offres trouvés ({len(items)} récupérés)")
    except Exception as e:
        print(f"  ✗ Erreur API BOAMP : {e}")
        return

    if not items:
        print("  Aucun résultat.")
        return

    # 2. Afficher un résumé
    print()
    for ao in items:
        status = f" [LIMITE: {ao['dateLimite']}]" if ao["dateLimite"] else ""
        print(f"  • [{ao['dateParution']}]{status} {ao['objet'][:80]}")
        print(f"    {ao['acheteur']} — {ao['url']}")
    print()

    # 3. Archiver dans Alfresco (optionnel — désactivé en mode CRON)
    cron_mode = os.environ.get("CRON_MODE", "").lower() == "true"
    if cron_mode:
        print("Mode affichage uniquement — aucun archivage.")
        return

    auto = os.environ.get("AUTO_ARCHIVE", "").lower() == "true"
    if auto:
        archive = "o"
    else:
        try:
            archive = input("Archiver dans Alfresco GED ? [o/N] ").strip().lower()
        except EOFError:
            archive = "n"
    if archive != "o":
        print("Archivage ignoré.")
        return

    folder_id = ensure_folder(ALFRESCO_FOLDER_PATH)
    if not folder_id:
        print("  ✗ Impossible d'accéder au dossier Alfresco.")
        return

    new_count = 0
    for ao in items:
        created = archive_ao_in_alfresco(ao, folder_id)
        if created:
            new_count += 1
            print(f"  + Archivé : {ao['id']} — {ao['objet'][:60]}")

    print(f"\n  ✓ {new_count} nouveau(x) AO archivé(s) dans Alfresco.")


if __name__ == "__main__":
    main()
