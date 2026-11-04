var aoData = '{"total":0,"items":[],"error":"Service indisponible"}';

try {
    var connector = remote.connect("alfresco-admin-service");
    var res = connector.get("/burinfort/appels-offres/boamp");
    if (res.status.code == 200) {
        aoData = res.response;
    } else {
        aoData = '{"total":0,"items":[],"error":"HTTP ' + res.status.code + '"}';
    }
} catch (e) {
    aoData = '{"total":0,"items":[],"error":"' + ("" + e).replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '"}';
}

model.aoData = aoData;
