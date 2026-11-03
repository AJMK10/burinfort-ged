<#assign el = args.htmlid?html />
<div id="${el}-body" style="font-family:Arial,sans-serif;background:#fff;border-radius:8px;overflow:hidden;border:1px solid #e8e8e8;">

   <!-- Header -->
   <div style="background:#C62828;padding:14px 20px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;">
      <div style="color:#fff;font-weight:800;font-size:15px;letter-spacing:.3px;">
         BURINFORT GED &mdash; Inscriptions
      </div>
      <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
         <#if pendingCount gt 0>
         <span style="background:#ffc107;color:#856404;font-weight:700;font-size:12px;padding:3px 10px;border-radius:12px;">
            &#9203; ${pendingCount} en attente
         </span>
         </#if>
         <span style="background:rgba(255,255,255,.2);color:#fff;font-size:12px;padding:3px 10px;border-radius:12px;">
            ${assignedCount} assign&eacute;(s)
         </span>
         <span style="background:rgba(255,255,255,.15);color:#ffcdd2;font-size:12px;padding:3px 10px;border-radius:12px;">
            ${totalCount} total
         </span>
      </div>
   </div>

   <!-- SECTION 1 : EN ATTENTE -->
   <div style="padding:0;">
      <div style="background:#fff8e1;border-bottom:2px solid #ffc107;padding:10px 20px;display:flex;align-items:center;gap:8px;">
         <span style="font-size:14px;font-weight:700;color:#856404;">&#9203; En attente d&apos;attribution</span>
         <span style="background:#ffc107;color:#856404;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;">${pendingCount}</span>
      </div>
      <#if pendingUsers?has_content>
      <table style="width:100%;border-collapse:collapse;font-size:13px;">
         <thead>
            <tr style="background:#fffde7;border-bottom:1px solid #ffe082;">
               <th style="padding:8px 16px;text-align:left;color:#374151;font-weight:600;">Nom</th>
               <th style="padding:8px 16px;text-align:left;color:#374151;font-weight:600;">Identifiant</th>
               <th style="padding:8px 16px;text-align:left;color:#374151;font-weight:600;">E-mail</th>
               <th style="padding:8px 16px;text-align:center;color:#374151;font-weight:600;">Documents</th>
               <th style="padding:8px 16px;text-align:center;color:#374151;font-weight:600;">Action</th>
            </tr>
         </thead>
         <tbody>
            <#list pendingUsers as u>
            <tr style="border-bottom:1px solid #fff9c4;background:#fffbeb;">
               <td style="padding:8px 16px;font-weight:600;color:#1a1a2e;">${u.firstName?html} ${u.lastName?html}</td>
               <td style="padding:8px 16px;color:#555;font-family:monospace;">${u.id?html}</td>
               <td style="padding:8px 16px;color:#555;">${u.email?html}</td>
               <td style="padding:8px 16px;text-align:center;">
                  <span style="background:#e3f2fd;color:#1565c0;font-weight:700;padding:3px 10px;border-radius:10px;font-size:12px;">
                     ${u.docCount?c}
                  </span>
               </td>
               <td style="padding:8px 16px;text-align:center;">
                  <a href="${url.context}/page/console/admin-console/users#state=panel%3Dview%26userid%3D${u.id?url}"
                     style="font-size:11px;background:#C62828;color:#fff;padding:3px 10px;border-radius:6px;text-decoration:none;font-weight:600;white-space:nowrap;">
                     Assigner
                  </a>
               </td>
            </tr>
            </#list>
         </tbody>
      </table>
      <#else>
      <div style="padding:16px 20px;color:#2e7d32;font-size:13px;font-style:italic;background:#f1f8e9;border-bottom:1px solid #c8e6c9;">
         &#10003; Tous les utilisateurs sont assign&eacute;s &agrave; un groupe.
      </div>
      </#if>
   </div>

   <!-- SECTION 2 : PAR SERVICE -->
   <div style="padding:0;">
      <div style="background:#e8f5e9;border-bottom:2px solid #a5d6a7;padding:10px 20px;display:flex;align-items:center;gap:8px;">
         <span style="font-size:14px;font-weight:700;color:#2e7d32;">&#10003; Assign&eacute;s par service</span>
         <span style="background:#a5d6a7;color:#1b5e20;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;">${assignedCount}</span>
      </div>
      <#if groupSections?has_content>
         <#list groupSections as section>
         <div style="border-bottom:1px solid #f0f0f0;">
            <div style="background:#f9fafb;padding:8px 16px;display:flex;align-items:center;gap:8px;border-bottom:1px solid #e8e8e8;">
               <span style="font-size:13px;font-weight:700;color:#1a1a2e;">&#128193; ${section.name?html}</span>
               <span style="background:#e8f5e9;color:#2e7d32;font-size:11px;font-weight:700;padding:2px 7px;border-radius:10px;">${section.users?size} utilisateur<#if section.users?size gt 1>s</#if></span>
            </div>
            <table style="width:100%;border-collapse:collapse;font-size:13px;">
               <thead>
                  <tr style="background:#f9fafb;border-bottom:1px solid #e8e8e8;">
                     <th style="padding:7px 16px;text-align:left;color:#374151;font-weight:600;width:28%;">Nom</th>
                     <th style="padding:7px 16px;text-align:left;color:#374151;font-weight:600;width:22%;">Identifiant</th>
                     <th style="padding:7px 16px;text-align:left;color:#374151;font-weight:600;">E-mail</th>
                     <th style="padding:7px 16px;text-align:center;color:#374151;font-weight:600;width:100px;">Documents</th>
                  </tr>
               </thead>
               <#list section.users as u>
               <tr style="border-bottom:1px solid #f5f5f5;">
                  <td style="padding:7px 16px;font-weight:600;color:#1a1a2e;">${u.firstName?html} ${u.lastName?html}</td>
                  <td style="padding:7px 16px;color:#555;font-family:monospace;">${u.id?html}</td>
                  <td style="padding:7px 16px;color:#555;">${u.email?html}</td>
                  <td style="padding:7px 16px;text-align:center;">
                     <span style="background:#e3f2fd;color:#1565c0;font-weight:700;padding:3px 10px;border-radius:10px;font-size:12px;">
                        ${u.docCount?c}
                     </span>
                  </td>
               </tr>
               </#list>
            </table>
         </div>
         </#list>
      <#else>
      <div style="padding:16px 20px;color:#9ca3af;font-size:13px;font-style:italic;">
         Aucun utilisateur assign&eacute; pour l&apos;instant.
      </div>
      </#if>
   </div>

   <!-- Footer -->
   <div style="padding:10px 20px;background:#fafafa;border-top:1px solid #e8e8e8;text-align:right;">
      <a href="${url.context}/page/console/admin-console/users"
         style="font-size:12px;color:#C62828;text-decoration:none;font-weight:600;">
         G&eacute;rer les utilisateurs &#8594;
      </a>
   </div>

</div>
