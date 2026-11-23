try {
    var cacheNode = companyhome.childByNamePath("Veille/marches-ci-cache.json");
    if (cacheNode != null) {
        model.cacheContent = cacheNode.content;
        model.found = true;
        model.errMsg = "";
    } else {
        model.found = false;
        model.errMsg = "node-null";
    }
} catch(e) {
    model.found = false;
    model.errMsg = e.toString();
}
