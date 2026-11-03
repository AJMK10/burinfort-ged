<@markup id="html">
   <@uniqueIdDiv>
      <#assign el=args.htmlid?html>

      <style>
         body.alfresco-guest,
         body.alfresco-guest .sticky-wrapper,
         body.alfresco-guest #doc3 { background:#f7f8fa !important; min-height:100vh !important; }
         body.alfresco-guest .sticky-wrapper {
            display:flex !important; flex-direction:column !important;
            align-items:center !important; justify-content:center !important;
            min-height:100vh !important; padding:32px 0 !important;
         }
         .rp-card {
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
         .ged-field input[type=password] {
            display:block !important; width:100% !important;
            padding:9px 12px !important; border:1.5px solid #d1d5db !important;
            border-radius:6px !important; font-size:0.88rem !important;
            color:#111827 !important; background:#fff !important;
            box-sizing:border-box !important; outline:none !important;
            font-family:inherit !important;
         }
         .ged-field input[type=password]:focus { border-color:#C62828 !important; box-shadow:0 0 0 3px rgba(198,40,40,0.08) !important; }
         .ged-btn {
            display:block; width:100%; padding:10px; background:#C62828; color:#fff;
            border:none; border-radius:6px; font-size:0.92rem; font-weight:700;
            cursor:pointer; margin-top:8px;
         }
         .ged-btn:hover { background:#b71c1c; }
         .ged-btn:disabled { background:#ccc; cursor:not-allowed; }
         .ged-msg { border-radius:6px; padding:10px 14px; font-size:0.84rem; margin-bottom:12px; display:none; }
         .ged-msg.success { background:#e8f5e9; color:#2e7d32; border:1px solid #a5d6a7; }
         .ged-msg.error { background:#ffebee; color:#c62828; border:1px solid #ef9a9a; }
         .ged-back { text-align:center; margin-top:16px; font-size:0.82rem; color:#888; }
         .ged-back a { color:#C62828; text-decoration:none; font-weight:600; }
         .ged-strength { font-size:0.75rem; margin-top:3px; }
      </style>

      <div class="rp-card">
         <div class="ged-logo-wrap">
            <img src="${url.context}/themes/bordeaux/images/logo.jpg" alt="BURINFORT GED" />
         </div>
         <h1 class="ged-title">Nouveau mot de passe</h1>
         <p class="ged-subtitle">Choisissez un mot de passe s&eacute;curis&eacute; (8 caract&egrave;res minimum).</p>

         <div id="${el}-msg" class="ged-msg"></div>

         <form id="${el}-form" onsubmit="rpSubmit(event)" style="display:none;">
            <div class="ged-field">
               <label for="${el}-pw">Nouveau mot de passe</label>
               <input type="password" id="${el}-pw" name="password" required minlength="8"
                      placeholder="Minimum 8 caract&egrave;res" oninput="checkStrength(this.value)" />
               <div id="${el}-strength" class="ged-strength"></div>
            </div>
            <div class="ged-field">
               <label for="${el}-pw2">Confirmer le mot de passe</label>
               <input type="password" id="${el}-pw2" name="password2" required minlength="8"
                      placeholder="Retapez le mot de passe" />
            </div>
            <button type="submit" id="${el}-btn" class="ged-btn">Enregistrer le mot de passe</button>
         </form>

         <div class="ged-back">
            <a href="${url.context}/page/type/forgot-password">&larr; Nouvelle demande</a>
            &nbsp;&nbsp;
            <a href="${url.context}/page/type/login">Connexion</a>
         </div>
      </div>

      <script type="text/javascript">//<![CDATA[
         // Read token from page URL query string (Surf doesn't pass page params to component)
         var RESET_TOKEN = (function() {
            var m = window.location.search.match(/[?&]token=([^&]+)/);
            return m ? decodeURIComponent(m[1]) : "";
         })();
         // Show form or error based on token presence
         (function() {
            var msg  = document.getElementById("${el}-msg");
            var form = document.getElementById("${el}-form");
            if (!RESET_TOKEN) {
               msg.className = "ged-msg error";
               msg.textContent = "Lien invalide ou expiré. Veuillez refaire une demande.";
               msg.style.display = "block";
            } else {
               form.style.display = "block";
            }
         })();

         function checkStrength(pw) {
            var el = document.getElementById("${el}-strength");
            if (!el) return;
            if (pw.length < 8) { el.style.color="#c62828"; el.textContent="Trop court"; return; }
            var score = 0;
            if (/[A-Z]/.test(pw)) score++;
            if (/[a-z]/.test(pw)) score++;
            if (/[0-9]/.test(pw)) score++;
            if (/[^A-Za-z0-9]/.test(pw)) score++;
            var labels = ["","Faible","Moyen","Fort","Très fort"];
            var colors = ["","#e53935","#fb8c00","#43a047","#1b5e20"];
            el.style.color = colors[score] || "#888";
            el.textContent = labels[score] || "";
         }

         function rpSubmit(e) {
            e.preventDefault();
            var btn  = document.getElementById("${el}-btn");
            var msg  = document.getElementById("${el}-msg");
            var pw   = document.getElementById("${el}-pw").value;
            var pw2  = document.getElementById("${el}-pw2").value;

            msg.style.display = "none";
            if (pw !== pw2) {
               msg.className = "ged-msg error";
               msg.textContent = "Les mots de passe ne correspondent pas.";
               msg.style.display = "block";
               return;
            }
            if (pw.length < 8) {
               msg.className = "ged-msg error";
               msg.textContent = "Le mot de passe doit comporter au moins 8 caractères.";
               msg.style.display = "block";
               return;
            }

            btn.disabled = true;
            btn.textContent = "Enregistrement...";

            var xhr = new XMLHttpRequest();
            xhr.open("POST", "${url.context}/service/components/guest/reset-password");
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.onreadystatechange = function() {
               if (xhr.readyState !== 4) return;
               btn.disabled = false;
               btn.textContent = "Enregistrer le mot de passe";
               try {
                  var resp = JSON.parse(xhr.responseText);
                  if (resp.success) {
                     msg.className = "ged-msg success";
                     msg.textContent = "Mot de passe mis à jour ! Redirection vers la connexion...";
                     msg.style.display = "block";
                     document.getElementById("${el}-form").style.display = "none";
                     setTimeout(function(){ window.location.href = "${url.context}/page/type/login"; }, 2500);
                  } else {
                     msg.className = "ged-msg error";
                     msg.textContent = resp.message || "Erreur. Le lien est peut-être expiré.";
                     msg.style.display = "block";
                  }
               } catch(ex) {
                  msg.className = "ged-msg error";
                  msg.textContent = "Erreur serveur (" + xhr.status + "). Réessayez.";
                  msg.style.display = "block";
               }
            };
            xhr.send(JSON.stringify({ token: RESET_TOKEN, password: pw }));
         }
      //]]></script>
   </@>
</@>
