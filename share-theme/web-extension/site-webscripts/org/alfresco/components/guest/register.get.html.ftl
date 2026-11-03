<@markup id="html">
   <@uniqueIdDiv>
      <#assign el=args.htmlid?html>

      <style>
         /* ── PAGE ───────────────────────────────────────────────── */
         body.alfresco-guest,
         body.alfresco-guest .sticky-wrapper,
         body.alfresco-guest #doc3 {
            background: #f7f8fa !important;
            min-height: 100vh !important;
         }
         body.alfresco-guest .sticky-wrapper {
            display: flex !important;
            flex-direction: column !important;
            align-items: center !important;
            justify-content: center !important;
            min-height: 100vh !important;
            padding: 32px 0 !important;
         }

         /* ── CARD ───────────────────────────────────────────────── */
         .reg-card {
            background: #ffffff;
            border-radius: 8px;
            padding: 36px 44px 32px;
            width: 480px;
            max-width: 92vw;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 4px 24px rgba(0,0,0,0.08);
            border: 1px solid #e8e8e8;
            box-sizing: border-box;
         }

         /* ── LOGO + HEADER ──────────────────────────────────────── */
         .ged-logo-wrap { text-align: center; margin-bottom: 8px; }
         .ged-logo-wrap img { height: 40px; width: auto; object-fit: contain; }
         .ged-title {
            font-size: 1.1rem; font-weight: 700; color: #1a1a2e;
            text-align: center; margin: 0 0 4px; letter-spacing: -0.01em;
         }
         .ged-subtitle {
            font-size: 0.8rem; color: #888;
            text-align: center; margin: 0 0 24px;
         }

         /* ── FORM ROW (2 columns) ───────────────────────────────── */
         .reg-row-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
         }

         /* ── FIELDS ─────────────────────────────────────────────── */
         .ged-field { margin-bottom: 14px; }
         .ged-field label {
            display: block; font-size: 0.82rem; font-weight: 600;
            color: #374151; margin-bottom: 4px;
         }
         .ged-input-wrap { position: relative; }
         .ged-input-wrap .ged-icon {
            position: absolute; left: 11px; top: 50%;
            transform: translateY(-50%); color: #9ca3af;
            pointer-events: none; display: flex;
         }
         .ged-field input[type=text],
         .ged-field input[type=email],
         .ged-field input[type=password] {
            display: block !important;
            width: 100% !important;
            padding: 9px 36px 9px 35px !important;
            border: 1.5px solid #d1d5db !important;
            border-radius: 6px !important;
            font-size: 0.88rem !important;
            color: #111827 !important;
            background: #ffffff !important;
            box-sizing: border-box !important;
            outline: none !important;
            transition: border-color 0.15s, box-shadow 0.15s !important;
            font-family: inherit !important;
         }
         .ged-field input:focus {
            border-color: #C62828 !important;
            box-shadow: 0 0 0 3px rgba(198,40,40,0.10) !important;
         }
         .ged-field input.reg-error { border-color: #ef4444 !important; }
         .ged-field input::placeholder { color: #b0b7c3 !important; }

         /* ── PASSWORD TOGGLE ────────────────────────────────────── */
         .pwd-toggle {
            position: absolute; right: 10px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: #9ca3af; padding: 3px; display: flex; align-items: center;
            transition: color 0.15s;
         }
         .pwd-toggle:hover { color: #C62828; }

         /* ── MESSAGE BOX ────────────────────────────────────────── */
         .reg-msg {
            border-radius: 6px; padding: 10px 14px;
            font-size: 0.85rem; margin-bottom: 16px;
         }
         .reg-msg.success {
            background: #f0fdf4; border: 1px solid #86efac; color: #166534;
         }
         .reg-msg.error {
            background: #fef2f2; border: 1px solid #fca5a5; color: #b91c1c;
         }

         /* ── SUBMIT ─────────────────────────────────────────────── */
         .reg-submit {
            display: block !important; width: 100% !important;
            padding: 11px !important; background: #C62828 !important;
            color: #ffffff !important; border: none !important;
            border-radius: 6px !important; font-size: 0.92rem !important;
            font-weight: 600 !important; cursor: pointer !important;
            letter-spacing: 0.02em !important; box-sizing: border-box !important;
            transition: background 0.15s !important; font-family: inherit !important;
            margin-top: 4px !important;
         }
         .reg-submit:hover:not(:disabled) { background: #8E0000 !important; }
         .reg-submit:disabled {
            background: #e5a0a0 !important; cursor: not-allowed !important;
         }

         /* ── FOOTER LINKS ───────────────────────────────────────── */
         .reg-footer-link {
            text-align: center; margin-top: 18px;
            font-size: 0.83rem; color: #6b7280;
         }
         .reg-footer-link a {
            color: #C62828; font-weight: 600;
            text-decoration: none; margin-left: 4px;
         }
         .reg-footer-link a:hover { text-decoration: underline; }
         .reg-copy {
            color: #9ca3af; font-size: 0.7rem;
            text-align: center; margin-top: 18px;
         }

         /* ── FIELD HINT ─────────────────────────────────────────── */
         .ged-hint {
            font-size: 0.74rem; color: #9ca3af;
            margin-top: 3px; display: none;
         }
         .ged-hint.visible { display: block; color: #ef4444; }

         /* ── DIVIDER ────────────────────────────────────────────── */
         .reg-divider {
            border: none; border-top: 1px solid #f0f0f0;
            margin: 20px 0 16px;
         }
      </style>

      <div class="reg-card">

         <div class="ged-logo-wrap">
            <img src="${url.context}/themes/bordeaux/images/logo.jpg" alt="BURINFORT S.A." />
         </div>
         <div class="ged-title">Créer un compte BURINFORT GED</div>
         <div class="ged-subtitle">Gestion Électronique de Documents — Demande d'accès</div>

         <div id="${el}-msg" class="reg-msg" style="display:none;"></div>

         <form id="${el}-form" onsubmit="return false;">

            <div class="reg-row-2">
               <div class="ged-field">
                  <label for="${el}-firstName">Prénom <span style="color:#C62828;">*</span></label>
                  <div class="ged-input-wrap">
                     <span class="ged-icon">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                           <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
                        </svg>
                     </span>
                     <input type="text" id="${el}-firstName" placeholder="Jean" autocomplete="given-name" />
                  </div>
               </div>
               <div class="ged-field">
                  <label for="${el}-lastName">Nom <span style="color:#C62828;">*</span></label>
                  <div class="ged-input-wrap">
                     <span class="ged-icon">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                           <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
                        </svg>
                     </span>
                     <input type="text" id="${el}-lastName" placeholder="Dupont" autocomplete="family-name" />
                  </div>
               </div>
            </div>

            <div class="ged-field">
               <label for="${el}-userName">Nom d'utilisateur <span style="color:#C62828;">*</span></label>
               <div class="ged-input-wrap">
                  <span class="ged-icon">
                     <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                     </svg>
                  </span>
                  <input type="text" id="${el}-userName" placeholder="jean.dupont"
                         autocomplete="username" oninput="sanitizeUsername(this)" />
               </div>
               <div id="${el}-userName-hint" class="ged-hint">Lettres, chiffres, points et tirets uniquement.</div>
            </div>

            <div class="ged-field">
               <label for="${el}-email">Adresse e-mail <span style="color:#C62828;">*</span></label>
               <div class="ged-input-wrap">
                  <span class="ged-icon">
                     <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="2" y="4" width="20" height="16" rx="2"/>
                        <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>
                     </svg>
                  </span>
                  <input type="email" id="${el}-email"
                         placeholder="jean.dupont@burinfort.com" autocomplete="email" />
               </div>
            </div>

            <hr class="reg-divider" />

            <div class="ged-field">
               <label for="${el}-password">Mot de passe <span style="color:#C62828;">*</span></label>
               <div class="ged-input-wrap">
                  <span class="ged-icon">
                     <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                     </svg>
                  </span>
                  <input type="password" id="${el}-password" placeholder="Min. 8 caractères"
                         autocomplete="new-password" oninput="checkStrength(this.value)" />
                  <button type="button" class="pwd-toggle"
                     onclick="togglePwd('${el}-password', this)">
                     <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                     </svg>
                  </button>
               </div>
               <div id="${el}-strength" style="margin-top:4px;height:3px;border-radius:2px;background:#e5e7eb;overflow:hidden;">
                  <div id="${el}-strength-bar" style="height:100%;width:0%;transition:width 0.3s,background 0.3s;border-radius:2px;"></div>
               </div>
            </div>

            <div class="ged-field">
               <label for="${el}-confirm">Confirmer le mot de passe <span style="color:#C62828;">*</span></label>
               <div class="ged-input-wrap">
                  <span class="ged-icon">
                     <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                     </svg>
                  </span>
                  <input type="password" id="${el}-confirm" placeholder="Répétez le mot de passe"
                         autocomplete="new-password" />
                  <button type="button" class="pwd-toggle"
                     onclick="togglePwd('${el}-confirm', this)">
                     <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                     </svg>
                  </button>
               </div>
               <div id="${el}-confirm-hint" class="ged-hint">Les mots de passe ne correspondent pas.</div>
            </div>

            <button type="button" id="${el}-submit" class="reg-submit" onclick="doRegister()">
               Créer mon compte
            </button>

         </form>
      </div>

      <div class="reg-footer-link">
         Déjà un compte ?
         <a href="${url.context}/page/type/login">Se connecter</a>
      </div>
      <div class="reg-copy">&copy; 2024&ndash;2026 BURINFORT S.A. &mdash; Tous droits réservés</div>

      <script type="text/javascript">//<![CDATA[
      var _el = "${el}";

      function togglePwd(inputId, btn) {
         var inp = document.getElementById(inputId);
         if (!inp) return;
         inp.type = inp.type === 'password' ? 'text' : 'password';
         btn.style.color = inp.type === 'text' ? '#C62828' : '';
      }

      function sanitizeUsername(inp) {
         inp.value = inp.value.toLowerCase().replace(/[^a-z0-9.\-_]/g, '');
      }

      function checkStrength(pwd) {
         var bar = document.getElementById(_el + '-strength-bar');
         if (!bar) return;
         var score = 0;
         if (pwd.length >= 8)  score += 25;
         if (pwd.length >= 12) score += 15;
         if (/[A-Z]/.test(pwd)) score += 20;
         if (/[0-9]/.test(pwd)) score += 20;
         if (/[^A-Za-z0-9]/.test(pwd)) score += 20;
         bar.style.width = score + '%';
         bar.style.background = score < 40 ? '#ef4444' : score < 70 ? '#f59e0b' : '#22c55e';
      }

      function showMsg(type, text) {
         var el = document.getElementById(_el + '-msg');
         if (!el) return;
         el.className = 'reg-msg ' + type;
         el.innerHTML = text;
         el.style.display = 'block';
         el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }

      function setError(fieldSuffix, msg) {
         var inp = document.getElementById(_el + '-' + fieldSuffix);
         if (inp) inp.classList.add('reg-error');
         var hint = document.getElementById(_el + '-' + fieldSuffix + '-hint');
         if (hint && msg) { hint.textContent = msg; hint.classList.add('visible'); }
      }

      function clearErrors() {
         var inputs = document.querySelectorAll('.reg-card input');
         for (var i = 0; i < inputs.length; i++) inputs[i].classList.remove('reg-error');
         var hints = document.querySelectorAll('.ged-hint');
         for (var i = 0; i < hints.length; i++) hints[i].classList.remove('visible');
         var msg = document.getElementById(_el + '-msg');
         if (msg) msg.style.display = 'none';
      }

      function val(id) {
         var el = document.getElementById(_el + '-' + id);
         return el ? el.value.trim() : '';
      }

      function doRegister() {
         clearErrors();
         var firstName = val('firstName');
         var lastName  = val('lastName');
         var userName  = val('userName');
         var email     = val('email');
         var password  = document.getElementById(_el + '-password') ? document.getElementById(_el + '-password').value : '';
         var confirm   = document.getElementById(_el + '-confirm')  ? document.getElementById(_el + '-confirm').value  : '';

         var valid = true;
         if (!firstName) { setError('firstName', null); valid = false; }
         if (!lastName)  { setError('lastName',  null); valid = false; }
         if (!userName)  { setError('userName', 'Nom d\'utilisateur requis.'); valid = false; }
         if (!email || email.indexOf('@') < 1) { setError('email', null); valid = false; }
         if (password.length < 8) {
            setError('password', null);
            showMsg('error', 'Le mot de passe doit contenir au moins 8 caractères.');
            valid = false;
         }
         if (password !== confirm) {
            setError('confirm', null);
            var hint = document.getElementById(_el + '-confirm-hint');
            if (hint) { hint.classList.add('visible'); }
            valid = false;
         }
         if (!valid) return;

         var btn = document.getElementById(_el + '-submit');
         if (btn) { btn.disabled = true; btn.textContent = 'Création en cours...'; }

         var payload = JSON.stringify({
            userName: userName,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
         });

         var xhr = new XMLHttpRequest();
         xhr.open('POST', '${url.context}/service/components/guest/register', true);
         xhr.setRequestHeader('Content-Type', 'application/json');
         xhr.setRequestHeader('Accept', 'application/json');

         xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            if (btn) { btn.disabled = false; btn.textContent = 'Créer mon compte'; }

            if (xhr.status === 0) {
               showMsg('error', 'Impossible de joindre le serveur. Vérifiez votre connexion.');
               return;
            }
            try {
               var resp = JSON.parse(xhr.responseText);
               if (resp.success) {
                  showMsg('success',
                     '<strong>Compte créé avec succès !</strong><br/>' +
                     'Votre compte <strong>' + userName + '</strong> a été créé. ' +
                     'Vous pouvez maintenant <a href="${url.context}/page/type/login" ' +
                     'style="color:#166534;font-weight:600;">vous connecter</a>.');
                  document.getElementById(_el + '-form').style.display = 'none';
               } else {
                  showMsg('error', resp.message || 'Une erreur est survenue.');
               }
            } catch(e) {
               showMsg('error', 'Erreur serveur (' + xhr.status + '). Réessayez dans quelques instants.');
            }
         };

         xhr.onerror = function() {
            if (btn) { btn.disabled = false; btn.textContent = 'Créer mon compte'; }
            showMsg('error', 'Erreur de connexion au serveur. Vérifiez votre connexion et réessayez.');
         };

         xhr.send(payload);
      }
      //]]></script>

   </@>
</@>
