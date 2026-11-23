model.jsonResult = '{"total":0,"items":[],"error":null}';

try {
    var keywords = (args.q && args.q !== "") ? args.q
                   : "informatique OR logiciel OR numerique OR GED";
    var maxRows  = (args.rows && args.rows !== "") ? args.rows : "20";

    function pad2(n) { return (n < 10 ? "0" : "") + n; }
    var d = new Date();
    d.setDate(d.getDate() - 90);
    var dateFrom = d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate());
    var fullQ    = keywords + " AND dateparution:[" + dateFrom + " TO *]";

    var apiUrl = "https://boamp-datadila.opendatasoft.com/api/records/1.0/search/"
               + "?dataset=boamp"
               + "&q=" + encodeURIComponent(fullQ)
               + "&rows=" + maxRows
               + "&sort=-dateparution"
               + "&refine.nature=APPEL_OFFRE";

    var result = { total: 0, items: [], error: null };

    try {
        var urlObj = new java.net.URL(apiUrl);
        var conn   = urlObj.openConnection();
        conn.setRequestProperty("Accept", "application/json");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(20000);

        var reader = new java.io.BufferedReader(
            new java.io.InputStreamReader(conn.getInputStream(), "UTF-8")
        );
        var sb = new java.lang.StringBuilder();
        var line;
        while ((line = reader.readLine()) !== null) {
            sb.append(line);
        }
        reader.close();

        var data = JSON.parse("" + sb.toString());
        result.total = data.nhits || 0;

        if (data.records) {
            for (var i = 0; i < data.records.length; i++) {
                var f  = data.records[i].fields || {};
                var dl = f.datelimitereponse ? ("" + f.datelimitereponse) : "";
                result.items.push({
                    id:           "" + (f.id                   || data.records[i].recordid || ""),
                    objet:        "" + (f.objet                 || ""),
                    acheteur:     "" + (f.nomacheteur           || ""),
                    dateParution: "" + (f.dateparution          || ""),
                    dateLimite:   dl.length >= 10 ? dl.substring(0, 10) : "",
                    url:          "" + (f.url_avis              || ""),
                    nature:       "" + (f.nature_libelle        || ""),
                    typeMarche:   "" + (f.type_marche_facette   || ""),
                    procedure:    "" + (f.procedure_libelle     || ""),
                    perimetre:    "" + (f.famille_libelle       || "")
                });
            }
        }
    } catch (httpErr) {
        result.error = "Erreur API BOAMP : " + httpErr;
    }

    model.jsonResult = JSON.stringify(result);

} catch (topErr) {
    model.jsonResult = '{"total":0,"items":[],"error":"' + ("" + topErr).replace(/"/g, "'") + '"}';
}
