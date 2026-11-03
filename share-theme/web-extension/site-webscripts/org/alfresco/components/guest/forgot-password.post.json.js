var SECRET = "BURINFORT_GED_RESET_KEY_2024";

function esc(s) { return String(s || "").split("\\").join("\\\\").split('"').join('\\"'); }

function genToken(userId) {
   var expiry  = String(java.lang.System.currentTimeMillis() + 3600000); // 1h
   var payload = userId + "|" + expiry;
   var md = java.security.MessageDigest.getInstance("SHA-256");
   md.update(new java.lang.String(SECRET + "|" + payload).getBytes("UTF-8"));
   var hashBytes = md.digest();
   var sig = "";
   for (var b = 0; b < hashBytes.length; b++) {
      var hex = ((hashBytes[b] + 256) % 256).toString(16);
      sig += (hex.length == 1 ? "0" : "") + hex;
   }
   var rawToken = payload + "|" + sig;
   return String(java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(
      new java.lang.String(rawToken).getBytes("UTF-8")
   ));
}

var email = json.optString("email", "").trim().toLowerCase();

model.success = false;
model.message = "";

if (!email || email.length == 0) {
   model.message = "Adresse e-mail requise.";
   status.code = 400;
} else {
   var connector = remote.connect("alfresco-admin-register");

   // Search user by email via v1 People API
   var userId = null;
   var firstName = "";
   try {
      var encodedEmail = encodeURIComponent(email);
      var usersRes = connector.get("/-default-/public/alfresco/versions/1/people?maxItems=200&skipCount=0&fields=id,firstName,lastName,email");
      if (usersRes.status.code == 200) {
         var data = JSON.parse(usersRes.response);
         for (var i = 0; i < data.list.entries.length; i++) {
            var p = data.list.entries[i].entry;
            if (p.email && p.email.toLowerCase() == email) {
               userId    = p.id;
               firstName = p.firstName || "";
               break;
            }
         }
      }
   } catch (e) {}

   // Always respond "success" to avoid email enumeration
   model.success = true;

   if (userId) {
      try {
         var token   = genToken(userId);
         var baseUrl = url.serverPath + url.context;
         var resetUrl = baseUrl + "/page/type/reset-password?token=" + token;

         var payload = JSON.stringify({
            firstName: firstName,
            email:     email,
            resetUrl:  resetUrl
         });
         var emailConnector = remote.connect("alfresco-admin-service");
         emailConnector.post("/burinfort/register/reset-password-email", payload, "application/json");
      } catch (e) {}
   }
}
