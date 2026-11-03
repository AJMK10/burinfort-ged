<@markup id="css" >
   <@link href="${url.context}/res/components/footer/footer.css" group="footer"/>
</@>

<@markup id="js">
</@>

<@markup id="widgets">
   <@createWidgets/>
</@>

<@markup id="html">
   <@uniqueIdDiv>
      <#assign fc=config.scoped["Edition"]["footer"]>
      <div class="footer ${fc.getChildValue("css-class")!"footer-com"}" style="display:flex;align-items:center;justify-content:center;gap:14px;padding:10px 24px;">
         <img src="${url.context}/themes/bordeaux/images/logo.jpg"
              alt="BURINFORT S.A."
              style="height:24px;width:auto;object-fit:contain;vertical-align:middle;" />
         <span class="copyright" style="font-size:12px;color:#6c757d;">
            <strong>BURINFORT S.A.</strong> &mdash; Intégrateur de solutions IT &nbsp;|&nbsp; Plateforme GED<br/>
            &copy; 2024-2026 BURINFORT S.A. Tous droits réservés.
         </span>
      </div>
   </@>

<style>
/* BURINFORT SA — logo constraints (injected via footer, works with any theme) */
.alfresco-logo-only img,
.alfresco-logo-Logo img,
img.alfresco-logo-logo {
   height: 36px !important;
   max-height: 36px !important;
   width: auto !important;
   max-width: 150px !important;
   object-fit: contain !important;
}
.share-header-title,
.alfresco-header-LicenseWarning {
   max-height: 52px !important;
   overflow: hidden !important;
}
.dynamic-welcome .alf-user-welcome img,
.dynamic-welcome img[alt="BURINFORT S.A."] {
   height: 18px !important;
   max-height: 18px !important;
   max-width: 70px !important;
   width: auto !important;
   object-fit: contain !important;
}
</style>

<script>
(function() {
   var existing = document.querySelector('link[rel="icon"]');
   if (!existing) {
      var link = document.createElement('link');
      link.rel = 'icon';
      link.type = 'image/svg+xml';
      link.href = '${url.context}/themes/bordeaux/images/favicon.svg';
      document.head.appendChild(link);
   }
})();
</script>
</@>
