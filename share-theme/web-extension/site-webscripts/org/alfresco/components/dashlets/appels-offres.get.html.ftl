<#assign el=args.htmlid?html>
<div id="${el}" class="dashlet ao-dashlet">
   <div class="title">
      <span class="label">Appels d'offres — Informatique / DSI</span>
      <a id="${el}-refresh" href="${url.context}/page/user/${user.name}/dashboard" class="ao-refresh-btn" title="Actualiser la page">&#8635;</a>
   </div>
   <div class="body">
      <div id="${el}-content" class="ao-content">
         <div class="ao-loading">Chargement des appels d'offres...</div>
      </div>
   </div>
</div>

<script type="text/javascript">
(function () {
   var raw = ${aoData};
   var el  = document.getElementById("${el}-content");
   if (!el) return;

   if (raw.error && raw.error !== "null" && raw.error !== null) {
      el.innerHTML = '<div class="ao-msg ao-error">Erreur lors du chargement : ' + raw.error + '</div>';
      return;
   }
   if (!raw.items || raw.items.length === 0) {
      el.innerHTML = '<div class="ao-msg ao-empty">Aucun appel d\'offres trouvé.</div>';
      return;
   }

   var today = new Date().toISOString().substring(0, 10);
   var html  = '<div class="ao-summary">' + raw.total + ' résultats &mdash; ' + raw.items.length + ' affichés</div>';
   html += '<ul class="ao-list">';

   for (var i = 0; i < raw.items.length; i++) {
      var item    = raw.items[i];
      var expired = item.dateLimite && item.dateLimite < today ? ' ao-expired' : '';
      var title   = item.objet.length > 120 ? item.objet.substring(0, 117) + '...' : item.objet;
      html += '<li class="ao-item">';
      html += '<a href="' + item.url + '" target="_blank" class="ao-title">' + title + '</a>';
      html += '<div class="ao-meta">';
      if (item.typeMarche) html += '<span class="ao-badge">' + item.typeMarche + '</span> ';
      if (item.acheteur)   html += '<span class="ao-acheteur">' + item.acheteur + '</span>';
      if (item.dateParution) html += '<span class="ao-date"> · ' + item.dateParution + '</span>';
      if (item.dateLimite)   html += '<span class="ao-deadline' + expired + '"> · Limite&nbsp;: ' + item.dateLimite + '</span>';
      html += '</div>';
      html += '</li>';
   }
   html += '</ul>';
   el.innerHTML = html;
})();
</script>
