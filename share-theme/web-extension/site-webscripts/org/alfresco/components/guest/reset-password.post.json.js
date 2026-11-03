var SECRET = "BURINFORT_GED_RESET_KEY_2024";

model.success = false;
model.message = "";

var tokenRaw    = json.optString("token",    "");
var newPassword = json.optString("password", "");

if (!tokenRaw || !newPassword || newPassword.length < 8) {
   model.message = "Données invalides.";
   status.code = 400;
} else {
   var userId  = null;
   var expired = false;
   var invalid = false;

   try {
      var rawToken = String(new java.lang.String(
         java.util.Base64.getUrlDecoder().decode(tokenRaw)
      ));
      var parts = rawToken.split("|");
      if (parts.length !== 3) { invalid = true; }
      else {
         var tUserId = parts[0];
         var expiry  = parseFloat(parts[1]);
         var sig     = parts[2];

         if (java.lang.System.currentTimeMillis() > expiry) {
            expired = true;
         } else {
            var payload = tUserId + "|" + parts[1];
            var md = java.security.MessageDigest.getInstance("SHA-256");
            md.update(new java.lang.String(SECRET + "|" + payload).getBytes("UTF-8"));
            var hashBytes = md.digest();
            var expectedSig = "";
            for (var b = 0; b < hashBytes.length; b++) {
               var hex = ((hashBytes[b] + 256) % 256).toString(16);
               expectedSig += (hex.length == 1 ? "0" : "") + hex;
            }
            if (sig !== expectedSig) { invalid = true; }
            else { userId = tUserId; }
         }
      }
   } catch (e) { invalid = true; }

   if (invalid) {
      model.message = "Lien invalide. Veuillez refaire une demande.";
      status.code = 400;
   } else if (expired) {
      model.message = "Lien expiré (valable 1 heure). Veuillez refaire une demande.";
      status.code = 400;
   } else if (userId) {
      // Update password via v1 People API (admin connector)
      try {
         var connector = remote.connect("alfresco-admin-register");
         var updatePayload = JSON.stringify({ password: newPassword });
         var res = connector.put(
            "/-default-/public/alfresco/versions/1/people/" + encodeURIComponent(userId),
            updatePayload,
            "application/json"
         );
         if (res.status.code == 200) {
            model.success = true;
         } else {
            model.message = "Impossible de mettre à jour le mot de passe (code " + res.status.code + ").";
            status.code = 500;
         }
      } catch (e) {
         model.message = "Erreur interne. Réessayez.";
         status.code = 500;
      }
   }
}
