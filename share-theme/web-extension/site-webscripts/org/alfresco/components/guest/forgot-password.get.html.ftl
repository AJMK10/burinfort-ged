<@markup id="html">
   <@uniqueIdDiv>
      <#assign el=args.htmlid?html>

      <style>
         body.alfresco-guest,
         body.alfresco-guest .sticky-wrapper,
         body.alfresco-guest #doc3 {
            background:#f7f8fa !important; min-height:100vh !important;
         }
         body.alfresco-guest .sticky-wrapper {
            display:flex !important; flex-direction:column !important;
            align-items:center !important; justify-content:center !important;
            min-height:100vh !important; padding:32px 0 !important;
         }
         .fp-card {
            background:#fff; border-radius:8px; padding:36px 44px 32px;
            width:420px; max-width:92vw;
            box-shadow:0 1px 3px rgba(0,0,0,0.06),0 4px 24px rgba(0,0,0,0.08);
            border:1px solid #e8e8e8; box-sizing:border-box;
         }
         .ged-logo-wrap { text-align:center; margin-bottom:8px; }
         .ged-logo-wrap img { height:40px; width:auto; object-fit:contain; }
         .ged-title { font-size:1.1rem; font-weight:700; color:#1a1a2e; text-align:center; margin:0 0 4px; }
         .ged-subtitle { font-size:0.8rem; color:#888; text-align:center; margin:0 0 24px; }
         .ged-field { margin-bottom:16px; }
         .ged-field label { display:block; font-size:0.82rem; font-weight:600; color:#374151; margin-bottom:4px; }
         .ged-field input[type=email] {
            display:block !important; width:100% !important;
            padding:9px 12px !important; border:1.5px solid #d1d5db !important;
            border-radius:6px !important; font-size:0.88rem !important;
            color:#111827 !important; background:#fff !important;
            box-sizing:border-box !important; outline:none !important;
            font-family:inherit !important;
         }
         .ged-field input[type=email]:focus { border-color:#C62828 !important; box-shadow:0 0 0 3px rgba(198,40,40,0.08) !important; }
         .ged-btn {
            display:block; width:100%; padding:10px; background:#C62828; color:#fff;
            border:none; border-radius:6px; font-size:0.92rem; font-weight:700;
            cursor:pointer; letter-spacing:.02em; margin-top:8px;
         }
         .ged-btn:hover { background:#b71c1c; }
         .ged-btn:disabled { background:#ccc; cursor:not-allowed; }
         .ged-msg { border-radius:6px; padding:10px 14px; font-size:0.84rem; margin-bottom:12px; display:none; }
         .ged-msg.success { background:#e8f5e9; color:#2e7d32; border:1px solid #a5d6a7; }
         .ged-msg.error { background:#ffebee; color:#c62828; border:1px solid #ef9a9a; }
         .ged-back { text-align:center; margin-top:16px; font-size:0.82rem; color:#888; }
         .ged-back a { color:#C62828; text-decoration:none; font-weight:600; }
      </style>

      <div class="fp-card">
         <div class="ged-logo-wrap">
            <img src="${url.context}/themes/bordeaux/images/logo.jpg" alt="BURINFORT GED" />
         </div>
         <h1 class="ged-title">Mot de passe oubli&eacute;</h1>
         <p class="ged-subtitle">Entrez votre adresse e-mail — nous vous enverrons un lien de r&eacute;initialisation.</p>

         <div id="${el}-msg" class="ged-msg"></div>

         <form id="${el}-form" onsubmit="fpSubmit(event)">
            <div class="ged-field">
               <label for="${el}-email">Adresse e-mail</label>
               <input type="email" id="${el}-email" name="email" required placeholder="votre@email.com" />
            </div>
            <button type="submit" id="${el}-btn" class="ged-btn">Envoyer le lien</button>
         </form>

         <div class="ged-back">
            <a href="${url.context}/page/type/login">&larr; Retour &agrave; la connexion</a>
         </div>
      </div>

      <script type="text/javascript">//<![CDATA[
         function fpSubmit(e) {
            e.preventDefault();
            var btn = document.getElementById("${el}-btn");
            var msg = document.getElementById("${el}-msg");
            var email = document.getElementById("${el}-email").value.trim();
            btn.disabled = true;
            btn.textContent = "Envoi en cours...";
            msg.style.display = "none";
            msg.className = "ged-msg";

            var xhr = new XMLHttpRequest();
            xhr.open("POST", "${url.context}/service/components/guest/forgot-password");
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.onreadystatechange = function() {
               if (xhr.readyState !== 4) return;
               btn.disabled = false;
               btn.textContent = "Envoyer le lien";
               try {
                  var resp = JSON.parse(xhr.responseText);
                  if (resp.success) {
                     msg.className = "ged-msg success";
                     msg.textContent = "Un e-mail de réinitialisation a été envoyé si cette adresse est connue.";
                     msg.style.display = "block";
                     document.getElementById("${el}-form").style.display = "none";
                  } else {
                     msg.className = "ged-msg error";
                     msg.textContent = resp.message || "Une erreur est survenue. Réessayez.";
                     msg.style.display = "block";
                  }
               } catch(ex) {
                  msg.className = "ged-msg error";
                  msg.textContent = "Erreur serveur (" + xhr.status + "). Réessayez dans quelques instants.";
                  msg.style.display = "block";
               }
            };
            xhr.send(JSON.stringify({ email: email }));
         }
      //]]></script>
   </@>
</@>
