<#assign el = args.htmlid?html />
<div id="${el}-body" style="font-family:Arial,sans-serif;background:#fff;border-radius:8px;overflow:hidden;border:1px solid #e8e8e8;">

   <!-- Header -->
   <div style="background:#C62828;padding:14px 20px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;">
      <div style="color:#fff;font-weight:800;font-size:15px;letter-spacing:.3px;">
         &#128101; Mes coll&egrave;gues
      </div>
      <div style="display:flex;gap:8px;align-items:center;">
         <span style="background:rgba(255,255,255,.2);color:#fff;font-size:12px;padding:3px 10px;border-radius:12px;">
            ${totalColleagues} personne<#if totalColleagues gt 1>s</#if>
         </span>
         <span style="background:rgba(255,255,255,.15);color:#ffcdd2;font-size:12px;padding:3px 10px;border-radius:12px;">
            ${siteSections?size} site<#if siteSections?size gt 1>s</#if>
         </span>
      </div>
   </div>

   <!-- Sections par site -->
   <#if siteSections?has_content>
      <#list siteSections as section>
      <div style="border-bottom:1px solid #f0f0f0;">

         <!-- Site header -->
         <div style="background:#f5f5f5;padding:9px 16px;display:flex;align-items:center;gap:8px;border-bottom:1px solid #e8e8e8;">
            <span style="font-size:13px;font-weight:700;color:#1a1a2e;">&#127968; ${section.name?html}</span>
            <span style="background:#e8eaf6;color:#3949ab;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;">
               ${section.members?size} membre<#if section.members?size gt 1>s</#if>
            </span>
            <a href="${url.context}/page/site/${section.id?url}/site-members"
               style="margin-left:auto;font-size:11px;color:#C62828;text-decoration:none;font-weight:600;">
               Voir tous &#8594;
            </a>
         </div>

         <!-- Members list -->
         <div style="padding:8px 0;">
            <#list section.members as m>
            <div style="display:flex;align-items:center;gap:12px;padding:7px 16px;border-bottom:1px solid #fafafa;">

               <!-- Avatar initials -->
               <div style="width:36px;height:36px;border-radius:50%;background:#C62828;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:13px;flex-shrink:0;text-align:center;line-height:36px;">
                  <#if m.firstName?has_content>${m.firstName?substring(0,1)?upper_case}<#else>${m.id?substring(0,1)?upper_case}</#if><#if m.lastName?has_content>${m.lastName?substring(0,1)?upper_case}</#if>
               </div>

               <!-- Info -->
               <div style="flex:1;min-width:0;">
                  <div style="font-weight:600;color:#1a1a2e;font-size:13px;">
                     ${m.firstName?html} ${m.lastName?html}
                  </div>
                  <div style="font-size:11px;color:#9ca3af;">${m.email?html}</div>
               </div>

               <!-- Role badge -->
               <#if m.role?has_content>
               <span style="font-size:10px;color:#555;background:#f0f0f0;padding:2px 7px;border-radius:8px;white-space:nowrap;">
                  ${m.role?html}
               </span>
               </#if>

               <!-- Profile link -->
               <a href="${url.context}/page/user/${m.id?url}/profile"
                  style="font-size:11px;color:#C62828;text-decoration:none;white-space:nowrap;">Profil</a>
            </div>
            </#list>
         </div>
      </div>
      </#list>
   <#else>
   <div style="padding:24px;text-align:center;color:#9ca3af;font-style:italic;font-size:13px;">
      Vous n&apos;&ecirc;tes membre d&apos;aucun site pour le moment.
   </div>
   </#if>

   <!-- Footer -->
   <div style="padding:10px 20px;background:#fafafa;border-top:1px solid #e8e8e8;text-align:right;">
      <a href="${url.context}/page/user/${currentUserId?url}/profile"
         style="font-size:12px;color:#C62828;text-decoration:none;font-weight:600;">
         Mon profil &#8594;
      </a>
   </div>

</div>
