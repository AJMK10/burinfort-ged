var keywords = (args.q !== null && args.q !== undefined && args.q !== "") ? args.q
               : "informatique OR logiciel OR \"système information\" OR numérique OR GED";
var maxRows  = (args.rows !== null && args.rows !== undefined) ? args.rows : "20";

// Filtre sur les 90 derniers jours
var cal      = java.util.Calendar.getInstance();
cal.add(java.util.Calendar.DAY_OF_YEAR, -90);
var fmt      = new java.text.SimpleDateFormat("yyyy-MM-dd");
var dateFrom = fmt.format(cal.getTime());
var fullQ    = keywords + " AND dateparution:[" + dateFrom + " TO *]";

var apiBase = "https://boamp-datadila.opendatasoft.com/api/records/1.0/search/";
var params  = "?dataset=boamp"
            + "&q=" + encodeURIComponent(fullQ)
            + "&rows=" + maxRows
            + "&sort=-dateparution"
            + "&refine.nature=APPEL_OFFRE";

var result = { total: 0, items: [], error: null };

try {
    var urlObj = new java.net.URL(apiBase + params);
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
            var f = data.records[i].fields || {};
            result.items.push({
                id:           "" + (f.id           || data.records[i].recordid || ""),
                objet:        "" + (f.objet         || ""),
                acheteur:     "" + (f.nomacheteur   || ""),
                dateParution: "" + (f.dateparution  || ""),
                dateLimite:   f.datelimitereponse
                                ? ("" + f.datelimitereponse).substring(0, 10)
                                : "",
                url:          "" + (f.url_avis      || ""),
                nature:       "" + (f.nature_libelle     || ""),
                typeMarche:   "" + (f.type_marche_facette || ""),
                procedure:    "" + (f.procedure_libelle  || ""),
                perimetre:    "" + (f.famille_libelle    || "")
            });
        }
    }
} catch (e) {
    result.error = "" + e;
}

model.jsonResult = JSON.stringify(result);
