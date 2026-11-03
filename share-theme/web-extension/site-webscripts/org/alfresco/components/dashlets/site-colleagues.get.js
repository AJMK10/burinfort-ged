var currentUserId = user.id;
var connector     = remote.connect("alfresco-admin-register");
var siteSections  = [];
var totalColleagues = 0;

try {
   var sitesRes = connector.get("/-default-/public/alfresco/versions/1/people/" + currentUserId + "/sites?maxItems=50&skipCount=0");
   if (sitesRes.status.code == 200) {
      var sitesData   = JSON.parse(sitesRes.response);
      var siteEntries = sitesData.list.entries;

      for (var i = 0; i < siteEntries.length; i++) {
         var site     = siteEntries[i].entry;
         var siteId   = site.id;
         var siteName = site.title || siteId;

         var members = [];
         try {
            var mRes = connector.get("/-default-/public/alfresco/versions/1/sites/" + siteId + "/members?maxItems=100&skipCount=0");
            if (mRes.status.code == 200) {
               var mData = JSON.parse(mRes.response);
               for (var j = 0; j < mData.list.entries.length; j++) {
                  var entry  = mData.list.entries[j].entry;
                  var person = entry.person || {};
                  var pid    = person.id || entry.id || "";
                  if (pid && pid != currentUserId && pid != "admin" && pid != "guest") {
                     members.push({
                        id:        pid,
                        firstName: person.firstName || "",
                        lastName:  person.lastName  || "",
                        email:     person.email     || "",
                        role:      entry.role       || ""
                     });
                     totalColleagues++;
                  }
               }
            }
         } catch (me) {}

         if (members.length > 0) {
            siteSections.push({ id: siteId, name: siteName, members: members });
         }
      }
   }
} catch (e) {}

model.siteSections    = siteSections;
model.currentUserId   = currentUserId;
model.totalColleagues = totalColleagues;
