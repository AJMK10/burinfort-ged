<#assign el=args.htmlid?html>
<div id="${el}" class="dashlet ao-dashlet">
   <div class="title">
      <span class="label">Appels d'offres &mdash; Informatique / DSI</span>
      <a id="${el}-refresh" href="#" class="ao-refresh-btn" title="Actualiser">&#8635;</a>
   </div>
   <div class="body">
      <div id="${el}-content" class="ao-content">
         <div class="ao-loading">Chargement des appels d'offres&hellip;</div>
      </div>
   </div>
</div>

<script type="text/javascript">
(function () {
   var elContent = document.getElementById("${el}-content");
   var elRefresh = document.getElementById("${el}-refresh");
   if (!elContent) return;

   function pad2(n) { return (n < 10 ? "0" : "") + n; }
   function dateFrom(days) {
      var d = new Date();
      d.setDate(d.getDate() - days);
      return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate());
   }

   function load() {
      elContent.innerHTML = '<div class="ao-loading">Chargement&hellip;</div>';

      var keywords = "informatique OR logiciel OR numerique OR GED";
      var since    = dateFrom(90);
      var query    = keywords + " AND dateparution:[" + since + " TO *]";
      var url      = "https://boamp-datadila.opendatasoft.com/api/records/1.0/search/"
                   + "?dataset=boamp"
                   + "&q=" + encodeURIComponent(query)
                   + "&rows=20"
                   + "&sort=-dateparution"
                   + "&refine.nature=APPEL_OFFRE";

      var xhr = new XMLHttpRequest();
      xhr.open("GET", url, true);
      xhr.setRequestHeader("Accept", "application/json");
      xhr.onreadystatechange = function () {
         if (xhr.readyState !== 4) return;
         if (xhr.status !== 200) {
            elContent.innerHTML = '<div class="ao-msg ao-error">Erreur HTTP ' + xhr.status + '</div>';
            return;
         }
         try {
            var data  = JSON.parse(xhr.responseText);
            var total = data.nhits || 0;
            var recs  = data.records || [];
            if (recs.length === 0) {
               elContent.innerHTML = '<div class="ao-msg ao-empty">Aucun appel d\'offres trouvé.</div>';
               return;
            }
            var today = new Date().toISOString().substring(0, 10);
            var html  = '<div class="ao-summary">' + total + ' résultats &mdash; ' + recs.length + ' affichés</div>';
            html += '<ul class="ao-list">';
            for (var i = 0; i < recs.length; i++) {
               var f       = recs[i].fields || {};
               var objet   = (f.objet || "").substring(0, 120);
               var dl      = (f.datelimitereponse || "").substring(0, 10);
               var expired = dl && dl < today ? " ao-expired" : "";
               html += '<li class="ao-item">';
               if (f.url_avis) {
                  html += '<a href="' + f.url_avis + '" target="_blank" class="ao-title">' + objet + '</a>';
               } else {
                  html += '<span class="ao-title">' + objet + '</span>';
               }
               html += '<div class="ao-meta">';
               if (f.type_marche_facette) html += '<span class="ao-badge">' + f.type_marche_facette + '</span> ';
               if (f.nomacheteur)         html += '<span class="ao-acheteur">' + f.nomacheteur + '</span>';
               if (f.dateparution)        html += '<span class="ao-date"> &middot; ' + f.dateparution + '</span>';
               if (dl)                    html += '<span class="ao-deadline' + expired + '"> &middot; Limite : ' + dl + '</span>';
               html += '</div></li>';
            }
            html += '</ul>';
            elContent.innerHTML = html;
         } catch (e) {
            elContent.innerHTML = '<div class="ao-msg ao-error">Erreur de chargement : ' + e.message + '</div>';
         }
      };
      xhr.onerror = function () {
         elContent.innerHTML = '<div class="ao-msg ao-error">Impossible de contacter l\'API BOAMP.</div>';
      };
      xhr.send();
   }

   elRefresh.addEventListener("click", function (e) { e.preventDefault(); load(); });
   load();
})();
</script>
