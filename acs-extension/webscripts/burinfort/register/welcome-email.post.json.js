var firstName = json.optString("firstName", "");
var userName  = json.optString("userName",  "");
var email     = json.optString("email",     "");

if (!email || !userName) {
   status.code = 400;
   model.success = false;
   model.message = "email and userName are required";
} else {
   try {
      var mailAction = actions.create("mail");
      mailAction.parameters["to"]      = email;
      mailAction.parameters["from"]    = "ajmkprod@gmail.com";
      mailAction.parameters["subject"] = "Bienvenue sur BURINFORT GED - Votre compte a ete cree";
      mailAction.parameters["html"]    =
         "<!DOCTYPE html><html lang='fr'><body style='margin:0;padding:0;background:#f7f8fa;font-family:Arial,sans-serif;'>" +
         "<div style='max-width:520px;margin:32px auto;background:#ffffff;border-radius:8px;border:1px solid #e8e8e8;overflow:hidden;'>" +
         "<div style='background:#C62828;padding:20px 32px;'>" +
         "<span style='color:#ffffff;font-weight:800;font-size:18px;letter-spacing:.5px;'>BURINFORT GED</span>" +
         "<span style='color:#ffcdd2;font-size:12px;margin-left:10px;'>Gestion &#201;lectronique de Documents</span>" +
         "</div>" +
         "<div style='padding:32px;'>" +
         "<h2 style='color:#1a1a2e;font-size:1.15rem;margin:0 0 10px;'>Bienvenue, " + firstName + "&nbsp;!</h2>" +
         "<p style='color:#555;line-height:1.6;margin:0 0 20px;'>Votre compte sur la plateforme <strong>BURINFORT GED</strong> a &#233;t&#233; cr&#233;&#233; avec succ&#232;s.</p>" +
         "<div style='background:#f7f8fa;border-radius:6px;padding:12px 18px;margin:0 0 20px;border:1px solid #e8e8e8;'>" +
         "<div style='font-size:11px;color:#9ca3af;text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px;'>Nom d&#39;utilisateur</div>" +
         "<div style='font-weight:700;font-size:16px;color:#1a1a2e;'>" + userName + "</div>" +
         "</div>" +
         "<div style='background:#fff8e1;border-left:4px solid #ffc107;border-radius:0 6px 6px 0;padding:14px 18px;margin:0 0 20px;'>" +
         "<p style='margin:0 0 4px;font-weight:700;color:#856404;font-size:13px;'>&#9203; En attente d&#39;attribution</p>" +
         "<p style='margin:0;font-size:13px;color:#856404;line-height:1.5;'>" +
         "Veuillez rester en attente jusqu&#39;&#224; ce que l&#39;&#233;quipe de d&#233;veloppement " +
         "vous attribue &#224; un d&#233;partement ou un site." +
         "</p>" +
         "</div>" +
         "<p style='color:#555;line-height:1.6;margin:0 0 24px;'>" +
         "Pour l&#39;instant, vous avez acc&#232;s &#224; votre <strong>espace personnel</strong> " +
         "pour stocker vos propres fichiers." +
         "</p>" +
         "<a href='http://localhost:8085/share/page/type/login' " +
         "style='display:inline-block;background:#C62828;color:#ffffff;padding:12px 28px;" +
         "border-radius:6px;text-decoration:none;font-weight:bold;font-size:14px;'>Se connecter</a>" +
         "</div>" +
         "<div style='background:#f7f8fa;padding:16px 32px;border-top:1px solid #e8e8e8;text-align:center;'>" +
         "<p style='font-size:11px;color:#9ca3af;margin:0;'>" +
         "Contact&nbsp;: <a href='mailto:joseph.ahoulou@burinfort.com' style='color:#C62828;text-decoration:none;'>joseph.ahoulou@burinfort.com</a>" +
         "&nbsp;&mdash;&nbsp;<a href='https://www.burinfort.com' style='color:#C62828;text-decoration:none;'>burinfort.com</a><br/>" +
         "&#169; 2024&#8211;2026 BURINFORT S.A." +
         "</p>" +
         "</div>" +
         "</div></body></html>";

      mailAction.execute(roothome);

      model.success = true;
      model.message = "Email sent to " + email;
   } catch (e) {
      status.code = 500;
      model.success = false;
      model.message = "Failed to send email: " + e.message;
   }
}
