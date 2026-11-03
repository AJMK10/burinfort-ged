var firstName = json.optString("firstName", "Utilisateur");
var email     = json.optString("email",     "");
var resetUrl  = json.optString("resetUrl",  "");

if (!email || !resetUrl) {
   status.code = 400;
   model.success = false;
} else {
   var htmlBody =
      "<!DOCTYPE html><html><head><meta charset='UTF-8'>" +
      "<style>" +
      "body{font-family:Arial,sans-serif;background:#f7f8fa;margin:0;padding:0}" +
      ".wrap{max-width:580px;margin:32px auto;background:#fff;border-radius:10px;" +
      "      border:1px solid #e8e8e8;overflow:hidden}" +
      ".header{background:#C62828;padding:24px 32px;text-align:center}" +
      ".header h1{color:#fff;margin:0;font-size:20px;font-weight:800;letter-spacing:.5px}" +
      ".header p{color:#ffcdd2;margin:4px 0 0;font-size:13px}" +
      ".body{padding:32px}" +
      ".body p{color:#374151;font-size:14px;line-height:1.6;margin:0 0 16px}" +
      ".btn{display:inline-block;background:#C62828;color:#fff;padding:12px 28px;" +
      "     border-radius:6px;text-decoration:none;font-weight:700;font-size:15px;" +
      "     margin:16px 0}" +
      ".notice{font-size:12px;color:#9ca3af;margin-top:24px;padding-top:16px;" +
      "        border-top:1px solid #f0f0f0}" +
      ".footer{background:#fafafa;padding:14px 32px;text-align:center;" +
      "        font-size:11px;color:#9ca3af;border-top:1px solid #f0f0f0}" +
      "</style></head><body>" +
      "<div class='wrap'>" +
      "<div class='header'>" +
      "<h1>BURINFORT GED</h1>" +
      "<p>R&eacute;initialisation de votre mot de passe</p>" +
      "</div>" +
      "<div class='body'>" +
      "<p>Bonjour <strong>" + firstName + "</strong>,</p>" +
      "<p>Vous avez demand&eacute; &agrave; r&eacute;initialiser votre mot de passe sur <strong>BURINFORT GED</strong>.</p>" +
      "<p>Cliquez sur le bouton ci-dessous pour choisir un nouveau mot de passe :</p>" +
      "<p style='text-align:center'><a href='" + resetUrl + "' class='btn'>R&eacute;initialiser mon mot de passe</a></p>" +
      "<p>Ou copiez ce lien dans votre navigateur :</p>" +
      "<p style='word-break:break-all;font-size:12px;color:#6b7280'>" + resetUrl + "</p>" +
      "<div class='notice'>" +
      "<p>Ce lien est valable <strong>1 heure</strong>. Si vous n&apos;avez pas fait cette demande, ignorez cet e-mail — votre mot de passe ne sera pas modifi&eacute;.</p>" +
      "</div>" +
      "</div>" +
      "<div class='footer'>BURINFORT SA &bull; Syst&egrave;me GED &bull; Ne pas r&eacute;pondre &agrave; cet e-mail.</div>" +
      "</div></body></html>";

   var mailAction = actions.create("mail");
   mailAction.parameters["to"]      = email;
   mailAction.parameters["from"]    = "ajmkprod@gmail.com";
   mailAction.parameters["subject"] = "BURINFORT GED - Réinitialisation de votre mot de passe";
   mailAction.parameters["html"]    = htmlBody;
   mailAction.execute(roothome);

   model.success = true;
}
