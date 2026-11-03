<@markup id="css" >
   <@link rel="stylesheet" type="text/css" href="${url.context}/res/components/dashlets/dynamic-welcome.css" group="dashlets" />
</@>

<@markup id="js">
   <@script type="text/javascript" src="${url.context}/res/components/dashlets/dynamic-welcome.js" group="dashlets"/>
</@>

<@markup id="widgets">
   <@createWidgets group="dashlets"/>
</@>

<@markup id="html">
   <@uniqueIdDiv>
      <#if showDashlet>
         <#assign el=args.htmlid?html>
         <div id="${el}-get-started-panel-container"
              class="dashlet dynamic-welcome<#if args.dashboardType = "user"> alf-user-welcome</#if>"
              style="background:#222e3c;border:none;border-left:3px solid #C62828;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,0.2);margin-bottom:20px;">

            <div style="display:flex;align-items:center;gap:16px;padding:14px 20px;">

               <!-- Logo -->
               <div style="flex-shrink:0;">
                  <a href="https://www.burinfort.com" target="_blank" rel="noopener">
                     <img src="${url.context}/themes/bordeaux/images/logo.jpg"
                          alt="BURINFORT S.A."
                          style="height:18px;max-width:70px;width:auto;object-fit:contain;display:block;flex-shrink:0;" />
                  </a>
               </div>

               <!-- Séparateur bordeaux -->
               <div style="width:3px;height:40px;background:#C62828;border-radius:2px;flex-shrink:0;"></div>

               <!-- Message (prend tout l'espace disponible) -->
               <div style="flex:1;min-width:0;">
                  <p style="margin:0 0 3px;font-size:13px;font-weight:600;color:#ffffff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                     Contacter l'équipe R&amp;D de Burinfort
                  </p>
                  <p style="margin:0;font-size:12px;color:#adb5bd;line-height:1.5;">
                     Pour toute suggestion ou amélioration, écrivez-nous à
                     <a href="mailto:joseph.ahoulou@burinfort.com"
                        style="color:#ef9a9a;font-weight:500;text-decoration:none;">joseph.ahoulou@burinfort.com</a>
                     &nbsp;—&nbsp;
                     <a href="https://www.burinfort.com" target="_blank" rel="noopener"
                        style="color:#ef9a9a;font-weight:500;text-decoration:none;">burinfort.com</a>
                  </p>
               </div>

               

            </div>
         </div>
      </#if>
   </@>
</@>
