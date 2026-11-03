var connector = remote.connect("alfresco-admin-register");
var pendingUsers  = [];
var groupSections = [];   // [{ name, displayName, users: [] }]
var groupIndex    = {};   // groupId -> index in groupSections
var pendingCount  = 0;
var assignedCount = 0;

try {
   var usersRes = connector.get("/-default-/public/alfresco/versions/1/people?maxItems=100&skipCount=0&orderBy=firstName%20ASC");
   if (usersRes.status.code == 200) {
      var data    = JSON.parse(usersRes.response);
      var entries = data.list.entries;

      for (var i = 0; i < entries.length; i++) {
         var person = entries[i].entry;
         var userId = person.id;
         if (userId == "admin" || userId == "guest" || userId == "-system-" || userId == "System") continue;

         // Count documents created by this user
         var docCount = 0;
         try {
            var safeId = ("" + userId).split("\\").join("\\\\").split('"').join('\\"');
            var sq = "{\"query\":{\"query\":\"cm:creator:\\\"" + safeId + "\\\" AND TYPE:\\\"cm:document\\\"\",\"language\":\"afts\"},\"paging\":{\"maxItems\":1,\"skipCount\":0}}";
            var sRes = connector.post("/-default-/public/search/versions/1/search", sq, "application/json");
            if (sRes.status.code == 200) {
               var sData = JSON.parse(sRes.response);
               docCount = sData.list.pagination.totalItems || 0;
            }
         } catch (se) {}

         var userObj = {
            id:        userId,
            firstName: person.firstName || "",
            lastName:  person.lastName  || "",
            email:     person.email     || "",
            docCount:  docCount
         };

         var userGroups = [];
         try {
            var gRes = connector.get("/-default-/public/alfresco/versions/1/people/" + userId + "/groups?maxItems=20");
            if (gRes.status.code == 200) {
               var gData = JSON.parse(gRes.response);
               for (var j = 0; j < gData.list.entries.length; j++) {
                  var g = gData.list.entries[j].entry;
                  // Keep only custom admin-created groups — exclude site_* and GROUP_EVERYONE
                  var gid = "" + g.id;
                  // Exclude GROUP_EVERYONE and site role sub-groups (_SiteCollaborator etc.)
                  var isRoleGroup = gid.indexOf("_SiteCollaborator") >= 0 ||
                                    gid.indexOf("_SiteManager")      >= 0 ||
                                    gid.indexOf("_SiteConsumer")     >= 0 ||
                                    gid.indexOf("_SiteContributor")  >= 0;
                  if (gid != "GROUP_EVERYONE" && !isRoleGroup) {
                     var displayName;
                     if (gid.indexOf("GROUP_site_") === 0) {
                        // Site group — extract and format the site name
                        var siteName = gid.substring(11); // remove "GROUP_site_"
                        siteName = siteName.split("-").join(" ").split("_").join(" ");
                        displayName = siteName.charAt(0).toUpperCase() + siteName.slice(1);
                     } else {
                        displayName = g.displayName || gid.split("GROUP_").join("").split("_").join(" ");
                     }
                     userGroups.push({ id: gid, name: displayName });
                  }
               }
            }
         } catch (ge) {}

         if (userGroups.length == 0) {
            pendingCount++;
            pendingUsers.push(userObj);
         } else {
            assignedCount++;
            for (var k = 0; k < userGroups.length; k++) {
               var gId = userGroups[k].id;
               if (groupIndex[gId] === undefined) {
                  groupIndex[gId] = groupSections.length;
                  groupSections.push({ id: gId, name: userGroups[k].name, users: [] });
               }
               groupSections[groupIndex[gId]].users.push(userObj);
            }
         }
      }
   }
} catch (e) {}

model.pendingUsers  = pendingUsers;
model.groupSections = groupSections;
model.pendingCount  = pendingCount;
model.assignedCount = assignedCount;
model.totalCount    = pendingCount + assignedCount;
