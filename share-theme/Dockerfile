FROM docker.io/alfresco/alfresco-share:26.2.4

# Copy YUI assets + all images from lightTheme (sprites, icons, etc.)
RUN mkdir -p /usr/local/tomcat/webapps/share/themes/bordeaux/images && \
    cp -r /usr/local/tomcat/webapps/share/themes/lightTheme/yui \
         /usr/local/tomcat/webapps/share/themes/bordeaux/ && \
    cp /usr/local/tomcat/webapps/share/themes/lightTheme/images/* \
       /usr/local/tomcat/webapps/share/themes/bordeaux/images/

# Apply custom bordeaux theme files (presentation.css + logo — overrides lightTheme images)
COPY bordeaux/ /usr/local/tomcat/webapps/share/themes/bordeaux/

# Share looks for app-logo-48.png by convention — copy our logo under that name too
RUN cp /usr/local/tomcat/webapps/share/themes/bordeaux/images/logo.jpg \
       /usr/local/tomcat/webapps/share/themes/bordeaux/images/app-logo-48.png && \
    cp /usr/local/tomcat/webapps/share/themes/bordeaux/images/logo.jpg \
       /usr/local/tomcat/webapps/share/themes/bordeaux/images/app-logo.png

# Register the bordeaux theme descriptor
COPY site-data/themes/bordeaux.xml \
     /usr/local/tomcat/webapps/share/WEB-INF/classes/alfresco/site-data/themes/bordeaux.xml

# Force the site to use bordeaux instead of the hardcoded lightTheme
COPY site-data/configurations/slingshot.site.configuration.xml \
     /usr/local/tomcat/webapps/share/WEB-INF/classes/alfresco/site-data/configurations/slingshot.site.configuration.xml

# Register custom pages (register, forgot-password, reset-password)
RUN mkdir -p /usr/local/tomcat/webapps/share/WEB-INF/classes/alfresco/site-data/pages/type
COPY site-data/pages/type/ \
     /usr/local/tomcat/webapps/share/WEB-INF/classes/alfresco/site-data/pages/type/

# Activate theme + CSRF config
COPY web-extension/share-config-custom.xml \
     /usr/local/tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml

# Custom footer (replaces Alfresco branding with BURINFORT SA)
COPY web-extension/site-webscripts/ \
     /usr/local/tomcat/shared/classes/alfresco/web-extension/site-webscripts/
