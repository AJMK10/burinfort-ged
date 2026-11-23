<#assign el=args.htmlid?html>
<div id="${el}" class="dashlet ao-dashlet">
   <div class="title">
      <span class="label">&#127464;&#127470; Appels d&rsquo;offres &mdash; C&ocirc;te d&rsquo;Ivoire</span>
      <a id="${el}-refresh" href="#" class="ao-refresh-btn" title="Actualiser">&#8635;</a>
   </div>
   <div class="body">
      <div id="${el}-summary" class="ao-summary-bar"></div>
      <div id="${el}-filter-bar" class="ao-filter-bar" style="display:none">
         <span class="ao-filter-icon">&#128269;</span>
         <input id="${el}-filter-input" type="text" class="ao-filter-input" placeholder="Filtrer par mot-cl&eacute;…" />
         <button id="${el}-filter-clear" class="ao-filter-clear" title="Effacer">&#10005;</button>
      </div>
      <div id="${el}-content" class="ao-content">
         <div class="ao-loading"><span class="ao-spinner">&#9696;</span> Chargement&hellip;</div>
      </div>
      <div id="${el}-pagination" class="ao-pagination" style="display:none"></div>
   </div>
</div>

<script type="text/javascript">
(function () {
   var CI_URL = Alfresco.util.combinePaths(Alfresco.constants.PROXY_URI,
                   "/burinfort/appels-offres/marches-ci");

   var elContent    = document.getElementById("${el}-content");
   var elSummary    = document.getElementById("${el}-summary");
   var elRefresh    = document.getElementById("${el}-refresh");
   var elFilterBar  = document.getElementById("${el}-filter-bar");
   var elFilterIn   = document.getElementById("${el}-filter-input");
   var elFilterClr  = document.getElementById("${el}-filter-clear");
   var elPagination = document.getElementById("${el}-pagination");

   var PER_PAGE = 5;
   var allItems = [];
   var filtered = [];
   var page     = 0;

   /* ── localStorage : suivi "Nouveau" ─────────────────────── */
   var SEEN_KEY  = "ao_ci_seen_v1";
   var seenMap   = {};
   try { seenMap = JSON.parse(localStorage.getItem(SEEN_KEY) || "{}"); } catch(e) {}

   function markSeen(items) {
      var now = Date.now(), changed = false;
      items.forEach(function(it) {
         if (it.urlAvis && !seenMap[it.urlAvis]) {
            seenMap[it.urlAvis] = now; changed = true;
         }
      });
      if (changed) { try { localStorage.setItem(SEEN_KEY, JSON.stringify(seenMap)); } catch(e){} }
   }

   /* Un AO est "nouveau" s'il a été vu pour la 1ère fois il y a < 48h */
   function isNew(it) {
      if (!it.urlAvis || !seenMap[it.urlAvis]) return false;
      return (Date.now() - seenMap[it.urlAvis]) < 172800000; /* 48h */
   }

   /* ── Helpers ─────────────────────────────────────────────── */
   function esc(s) {
      return String(s||"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")
                          .replace(/"/g,"&quot;").replace(/'/g,"&#39;");
   }

   /* Les URLs proviennent de sites tiers scrapés : seules http(s) sont acceptées */
   function safeUrl(u) { return /^https?:\/\//i.test(u||"") ? esc(u) : ""; }

   function formatDate(d) {
      if (!d) return "";
      if (/^\d{2}\/\d{2}\/\d{4}$/.test(d)) return d;
      var p = d.substring(0,10).split("-");
      if (p.length===3 && p[0].length===4) return p[2]+"/"+p[1]+"/"+p[0];
      return d;
   }

   function daysLeft(dl) {
      if (!dl) return null;
      var m = dl.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
      if (m) { var d = new Date(+m[3], +m[2]-1, +m[1]); return Math.ceil((d-new Date())/86400000); }
      if (/^\d{4}-\d{2}-\d{2}/.test(dl)) return Math.ceil((new Date(dl.substring(0,10))-new Date())/86400000);
      return null;
   }

   function deadlineBadge(dl) {
      var d = daysLeft(dl); if (d===null) return "";
      if (d<0)   return '<span class="ao-dl-badge ao-dl-expired">Expir&eacute;</span>';
      if (d===0) return '<span class="ao-dl-badge ao-dl-today">Aujourd\'hui</span>';
      if (d<=7)  return '<span class="ao-dl-badge ao-dl-urgent">J&minus;'+d+'</span>';
      return             '<span class="ao-dl-badge ao-dl-ok">J&minus;'+d+'</span>';
   }

   function sourceClass(src) {
      var s=(src||"").toLowerCase();
      if (s.indexOf("dgmp")>=0)  return "ao-src-dgmp";
      if (s.indexOf("anrmp")>=0) return "ao-src-anrmp";
      if (s.indexOf("arcop")>=0) return "ao-src-arcop";
      if (s.indexOf("artci")>=0) return "ao-src-artci";
      if (s.indexOf("anader")>=0)return "ao-src-anader";
      return "ao-src-default";
   }

   /* ── Rendu d'une card ────────────────────────────────────── */
   function renderCard(it) {
      var rawTitre = it.titre||"";
      var titre = rawTitre.length>130 ? esc(rawTitre.substring(0,127))+"&hellip;" : esc(rawTitre);
      var acheteur = esc(it.acheteur||"");
      var showAcheteur = acheteur && !/^\d+$/.test(acheteur);
      var dp  = formatDate(it.datePublication||"");
      var dl  = it.dateLimite||"";
      var url = safeUrl(it.urlAvis);
      var src = it.source||"CI";
      var dlBadge = deadlineBadge(dl);
      var archived = !!it.isArchived;
      var score = it.aiScore||0;

      var html = '<li class="ao-card'+(archived?" ao-card-archived":"")+'">';

      /* Top : source + NEW + archived + date */
      html += '<div class="ao-card-top">';
      html += '<div class="ao-card-top-left">';
      html += '<span class="ao-src-badge '+sourceClass(src)+'">'+esc(src)+'</span>';
      if (isNew(it)) html += '<span class="ao-badge-new">&#10024;&nbsp;Nouveau</span>';
      if (archived)  html += '<span class="ao-badge-archived">Archiv&eacute;</span>';
      html += '</div>';
      if (dp) html += '<span class="ao-pub-date">'+dp+'</span>';
      html += '</div>';

      /* Titre */
      html += '<div class="ao-card-body">';
      if (url) {
         html += '<a href="'+url+'" target="_blank" rel="noopener" class="ao-card-title">'+titre+'</a>';
      } else {
         html += '<span class="ao-card-title ao-card-title-plain">'+titre+'</span>';
      }
      html += '</div>';

      /* Résumé IA (collapsible) */
      if (it.aiSummary) {
         var cardId = "ao-ai-"+Math.random().toString(36).substr(2,6);
         html += '<details class="ao-ai-block">';
         html += '<summary class="ao-ai-summary-toggle">';
         if (score>0) html += '<span class="ao-score-badge '+(score>=70?"ao-score-high":score>=40?"ao-score-med":"ao-score-low")+'">'+score+'/100</span>';
         html += '&#129302;&nbsp;R&eacute;sum&eacute; IA</summary>';
         html += '<div class="ao-ai-content">'+esc(it.aiSummary)+'</div>';
         if (it.aiPoints && it.aiPoints.length) {
            html += '<ul class="ao-ai-points">';
            for (var k=0; k<it.aiPoints.length; k++) html += '<li>'+esc(it.aiPoints[k])+'</li>';
            html += '</ul>';
         }
         html += '</details>';
      }

      /* Footer : acheteur + budget + deadline/download */
      html += '<div class="ao-card-foot">';
      var leftParts = [];
      if (showAcheteur) leftParts.push('&#127970;&nbsp;'+acheteur);
      if (it.budget)    leftParts.push('&#128176;&nbsp;'+esc(it.budget));
      html += '<span class="ao-card-foot-left">'+leftParts.join(' &mdash; ')+'</span>';

      var right = dlBadge;
      if (!right && url) {
         right = '<a href="'+url+'" target="_blank" rel="noopener" class="ao-dl-btn">&#128196;&nbsp;T&eacute;l&eacute;charger</a>';
      }
      if (right) html += right;
      html += '</div>';

      html += '</li>';
      return html;
   }

   /* ── Pagination ──────────────────────────────────────────── */
   function renderPage() {
      var start = page * PER_PAGE;
      var slice = filtered.slice(start, start + PER_PAGE);
      if (slice.length === 0) {
         elContent.innerHTML = '<div class="ao-msg ao-empty">Aucun r&eacute;sultat.</div>';
         elPagination.style.display = "none";
         return;
      }
      var html = '<ul class="ao-card-list">';
      for (var i=0; i<slice.length; i++) html += renderCard(slice[i]);
      html += '</ul>';
      elContent.innerHTML = html;

      var totalPages = Math.ceil(filtered.length / PER_PAGE);
      if (totalPages > 1) {
         elPagination.style.display = "flex";
         elPagination.innerHTML =
            '<button class="ao-pg-btn" id="${el}-pg-prev" '+(page===0?"disabled":"")+'>&#9664; Pr&eacute;c.</button>'
            +'<span class="ao-pg-info">Page '+(page+1)+' / '+totalPages+'</span>'
            +'<button class="ao-pg-btn" id="${el}-pg-next" '+(page>=totalPages-1?"disabled":"")+'>Suiv. &#9654;</button>';
         document.getElementById("${el}-pg-prev").addEventListener("click", function(){if(page>0){page--;renderPage();}});
         document.getElementById("${el}-pg-next").addEventListener("click", function(){if(page<totalPages-1){page++;renderPage();}});
      } else {
         elPagination.style.display = "none";
      }
   }

   /* ── Filtre ──────────────────────────────────────────────── */
   function applyFilter() {
      var q = elFilterIn.value.toLowerCase().trim();
      filtered = q ? allItems.filter(function(it){ return (it.titre||"").toLowerCase().indexOf(q)>=0; }) : allItems.slice();
      page = 0;
      renderPage();
      updateSummaryCount();
   }

   function updateSummaryCount() {
      var q = elFilterIn.value.trim();
      var active = allItems.filter(function(it){ return !it.isArchived; }).length;
      var archived = allItems.filter(function(it){ return it.isArchived; }).length;
      var ts = allItems._generatedAt || "";
      var txt = '<strong>'+active+'</strong> appel(s) d\'offres IT';
      if (archived) txt += ' <span class="ao-archived-count">(+'+archived+'&nbsp;archiv&eacute;s)</span>';
      if (ts) txt += ' &mdash; mis &agrave; jour le '+ts;
      if (q) txt += ' &mdash; <strong>'+filtered.length+'</strong> r&eacute;sultat(s)';
      elSummary.innerHTML = txt;
   }

   /* ── Render principal ────────────────────────────────────── */
   function render(data) {
      if (data.error) {
         elContent.innerHTML = '<div class="ao-msg ao-warn"><strong>Cache non disponible</strong><br>'
            +'<small>Lancez : <code>docker compose -f compose/openclaw-compose.yaml run --rm ci-cron</code></small></div>';
         elFilterBar.style.display = "none"; elPagination.style.display = "none";
         return;
      }
      allItems = data.items || [];
      allItems._generatedAt = data.generatedAt || "";

      /* Marquer comme vus AVANT le rendu (pour éviter le flash "nouveau") */
      markSeen(allItems.filter(function(it){ return !it.isArchived; }));

      filtered = allItems.slice();
      page = 0;

      if (allItems.length > 0) elFilterBar.style.display = "flex"; else elFilterBar.style.display = "none";
      elFilterIn.value = "";

      updateSummaryCount();
      renderPage();
   }

   /* ── Chargement XHR ──────────────────────────────────────── */
   function load() {
      elContent.innerHTML = '<div class="ao-loading"><span class="ao-spinner">&#9696;</span> Chargement&hellip;</div>';
      elSummary.innerHTML = ""; elFilterBar.style.display = "none"; elPagination.style.display = "none";
      var xhr = new XMLHttpRequest();
      xhr.open("GET", CI_URL, true);
      xhr.setRequestHeader("Accept", "application/json");
      xhr.onreadystatechange = function () {
         if (xhr.readyState !== 4) return;
         if (xhr.status === 200) {
            try { render(JSON.parse(xhr.responseText)); }
            catch(e) { elContent.innerHTML = '<div class="ao-msg ao-error">Erreur JSON : '+e.message+'</div>'; }
         } else {
            elContent.innerHTML = '<div class="ao-msg ao-error">Erreur HTTP '+xhr.status+'</div>';
         }
      };
      xhr.onerror = function () { elContent.innerHTML = '<div class="ao-msg ao-error">Connexion impossible.</div>'; };
      xhr.send();
   }

   elRefresh.addEventListener("click", function(e){ e.preventDefault(); load(); });
   elFilterIn.addEventListener("input", applyFilter);
   elFilterClr.addEventListener("click", function(){ elFilterIn.value=""; applyFilter(); });
   load();
})();
</script>
