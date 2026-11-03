// Server-side registration handler — creates user + sends welcome email via Resend
var firstName = json.optString("firstName", "");
var lastName  = json.optString("lastName",  "");
var userName  = json.optString("userName",  "");
var email     = json.optString("email",     "");
var password  = json.optString("password",  "");

if (!firstName || !lastName || !userName || !email || !password) {
   status.code = 400;
   model.success = false;
   model.message = "Tous les champs sont obligatoires.";
} else {
   function esc(s) { return ("" + s).split("\\").join("\\\\").split('"').join('\\"'); }

   // 1. Create user via Alfresco People API (admin connector)
   var personJson = "{" +
      "\"id\":\""        + esc(userName)  + "\"," +
      "\"firstName\":\"" + esc(firstName) + "\"," +
      "\"lastName\":\""  + esc(lastName)  + "\"," +
      "\"email\":\""     + esc(email)     + "\"," +
      "\"password\":\""  + esc(password)  + "\"" +
   "}";

   var connector = remote.connect("alfresco-admin-register");
   var result = connector.post(
      "/-default-/public/alfresco/versions/1/people",
      personJson,
      "application/json"
   );

   var code = result.status.code;

   if (code == 201) {
      model.success = true;
      model.message = "Compte créé avec succès.";
      model.userName = userName;

      // 2. Send welcome email via ACS mail action (Gmail SMTP, best-effort)
      try {
         var emailPayload = "{" +
            "\"firstName\":\"" + esc(firstName) + "\"," +
            "\"userName\":\""  + esc(userName)  + "\"," +
            "\"email\":\""     + esc(email)     + "\"" +
         "}";
         var emailConnector = remote.connect("alfresco-admin-service");
         emailConnector.post("/burinfort/register/welcome-email", emailPayload, "application/json");
      } catch (mailErr) {
         // Email failure is non-blocking — account is created regardless
      }

   } else {
      model.success = false;
      var errMsg = "Erreur lors de la création du compte (" + code + ").";
      try {
         var resp = eval("(" + result.response + ")");
         if (resp && resp.error) {
            if (code == 409) {
               errMsg = "Ce nom d’utilisateur ou cet e-mail existe déjà.";
            } else if (resp.error.briefSummary) {
               errMsg = resp.error.briefSummary;
            }
         }
      } catch (e) {
         if (code == 409) errMsg = "Ce nom d’utilisateur ou cet e-mail existe déjà.";
      }
      model.message = errMsg;
      status.code = code;
   }
}
