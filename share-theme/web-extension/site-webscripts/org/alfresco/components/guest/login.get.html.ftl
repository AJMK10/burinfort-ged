<@markup id="css" >
   <@link href="${url.context}/res/components/guest/login.css" group="login"/>
</@>

<@markup id="js">
   <@script src="${url.context}/res/components/guest/login.js" group="login"/>
</@>

<@markup id="widgets">
   <@createWidgets group="login"/>
</@>

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
         /* Override Alfresco login padding so our card takes over */
         div.login { padding:0 !important; background:transparent !important; }
         .theme-overlay.login { box-shadow:none !important; border-radius:8px !important; }

         .buri-login-card {
            background:#fff; border-radius:8px; padding:36px 44px 32px;
            width:400px; max-width:92vw;
            box-shadow:0 1px 3px rgba(0,0,0,0.06),0 4px 24px rgba(0,0,0,0.08);
            border:1px solid #e8e8e8; box-sizing:border-box;
         }
         .buri-logo-wrap { text-align:center; margin-bottom:8px; }
         .buri-logo-wrap img { height:40px; width:auto; object-fit:contain; }
         .buri-title { font-size:1.1rem; font-weight:700; color:#1a1a2e; text-align:center; margin:0 0 4px; }
         .buri-subtitle { font-size:0.8rem; color:#888; text-align:center; margin:0 0 22px; }

         .buri-field { margin-bottom:14px; }
         .buri-field label {
            display:block; font-size:0.82rem; font-weight:600;
            color:#374151; margin-bottom:4px;
         }
         .buri-field input[type=text],
         .buri-field input[type=password] {
            display:block !important; width:100% !important;
            padding:9px 12px !important; border:1.5px solid #d1d5db !important;
            border-radius:6px !important; font-size:0.88rem !important;
            color:#111827 !important; background:#fff !important;
            box-sizing:border-box !important; outline:none !important;
            transition:border-color .15s,box-shadow .15s !important;
            font-family:inherit !important;
         }
         .buri-field input:focus {
            border-color:#C62828 !important;
            box-shadow:0 0 0 3px rgba(198,40,40,.08) !important;
         }
         .buri-btn {
            display:block !important; width:100% !important; padding:10px !important;
            background:#C62828 !important; color:#fff !important;
            border:none !important; border-radius:6px !important;
            font-size:0.92rem !important; font-weight:700 !important;
            cursor:pointer !important; margin-top:8px !important;
            letter-spacing:.02em !important; transition:background .15s !important;
            text-align:center !important;
         }
         .buri-btn:hover { background:#b71c1c !important; }
         .buri-error {
            background:#ffebee; color:#c62828; border:1px solid #ef9a9a;
            border-radius:6px; padding:9px 14px; font-size:0.84rem;
            margin-bottom:14px;
         }
         .buri-links {
            display:flex; flex-direction:column; align-items:center;
            gap:6px; margin-top:14px;
         }
         .buri-links a.forgot {
            font-size:0.82rem; color:#C62828; text-decoration:none; font-weight:600;
         }
         .buri-links a.register {
            font-size:0.79rem; color:#6b7280; text-decoration:none;
         }
         .buri-links a.register strong { color:#C62828; }
         .buri-copy {
            text-align:center; font-size:0.72rem; color:#aaa;
            margin-top:18px;
         }
      </style>

      <div id="${el}-body" class="theme-overlay login hidden">
         <div class="buri-login-card">
            <!-- Logo -->
            <div class="buri-logo-wrap">
               <img src="${url.context}/themes/bordeaux/images/logo.jpg" alt="BURINFORT GED" />
            </div>
            <h1 class="buri-title">BURINFORT GED</h1>
            <p class="buri-subtitle">Connectez-vous &agrave; votre espace documentaire</p>

            <#if error?? && error>
            <div class="buri-error">Identifiant ou mot de passe incorrect.</div>
            </#if>

            <form id="${el}-form" accept-charset="UTF-8" method="post"
                  action="${loginUrl}" class="form-fields login">
               <input type="hidden" id="${el}-success" name="success"
                      value="${successUrl?replace("@","%40")?html}"/>
               <input type="hidden" name="failure"
                      value="${failureUrl?replace("@","%40")?html}"/>

               <div class="buri-field">
                  <label for="${el}-username">Identifiant</label>
                  <input type="text" id="${el}-username" name="username" maxlength="255"
                         autocomplete="username" autofocus
                         value="<#if lastUsername??>${lastUsername?html}</#if>"
                         placeholder="Votre identifiant" />
               </div>
               <div class="buri-field">
                  <label for="${el}-password">Mot de passe</label>
                  <input type="password" id="${el}-password" name="password"
                         maxlength="255" autocomplete="current-password"
                         placeholder="Votre mot de passe" />
               </div>

               <button type="submit" id="${el}-submit" class="buri-btn">
                  Se connecter
               </button>
            </form>

            <div class="buri-links">
               <a class="forgot" href="${url.context}/page/type/forgot-password">
                  Mot de passe oubli&eacute;&nbsp;?
               </a>
               <a class="register" href="${url.context}/page/type/register">
                  Pas encore de compte&nbsp;? <strong>S&apos;inscrire</strong>
               </a>
            </div>
         </div>

         <div class="buri-copy">&copy; 2024 BURINFORT SA &mdash; Syst&egrave;me GED</div>
      </div>

      <@markup id="preloader">
         <script type="text/javascript">//<![CDATA[
            window.onload = function() {
               setTimeout(function() {
                  var xhr;
                  <#list dependencies as dependency>
                     xhr = new XMLHttpRequest();
                     xhr.open('GET', '<@checksumResource src="${url.context}/res/${dependency}"/>');
                     xhr.send('');
                  </#list>
                  <#list images as image>
                     new Image().src = "${url.context?js_string}/res/${image}";
                  </#list>
               }, 1000);
            };
         //]]></script>
      </@markup>
   </@>
</@>
