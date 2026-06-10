// host.jsx — ExtendScript for Cocos PSD Namer (CEP).
// Renames the currently SELECTED layers (supports multi-select) by adding /
// replacing a type prefix that the cocos-psd-prefab-2x converter understands.
#target photoshop

// Known type/ignore prefixes (order matters: longest first so lay_grid_ wins over lay_).
var CPX_PREFIXES = ['lay_grid_','lay_h_','lay_v_','lay_','btn_','sv_','sp_','lbl_','rt_',
    'node_','mask_','edit_','prog_','tog_','tmp_','ref_'];

function cpx_lc(s){ return String(s).toLowerCase(); }

// strip a leading known prefix (or leading "// ") so re-tagging replaces cleanly
function cpx_strip(name){
    var n = String(name);
    for (var i = 0; i < CPX_PREFIXES.length; i++){
        var p = CPX_PREFIXES[i];
        if (cpx_lc(n).indexOf(p) === 0){ return n.substring(p.length); }
    }
    if (n.indexOf('//') === 0){ return n.replace(/^\/\/\s*/, ''); }
    if (n.indexOf('!') === 0){ return n.substring(1); }
    return n;
}

// compute the new name for a given current name + chosen prefix
function cpx_newName(name, prefix, replace){
    var base = replace ? cpx_strip(name) : String(name);
    if (prefix === '')   return base;                 // clear prefix
    if (prefix === '//') return '// ' + base;         // mark as comment/ignore
    if (prefix === '!')  return '!' + base;           // mark as ignore
    if (cpx_lc(base).indexOf(cpx_lc(prefix)) === 0) return base; // already has it
    return prefix + base;
}

// ---- ActionManager helpers to read/rename SELECTED layers by ID ----

function cpx_hasBackground(){
    try {
        var ref = new ActionReference();
        ref.putProperty(charIDToTypeID("Prpr"), stringIDToTypeID("background"));
        ref.putEnumerated(charIDToTypeID("Lyr "), charIDToTypeID("Ordn"), charIDToTypeID("Back"));
        return executeActionGet(ref).getBoolean(stringIDToTypeID("background"));
    } catch (e) { return false; }
}

function cpx_layerIDByIndex(idx){
    var ref = new ActionReference();
    ref.putProperty(charIDToTypeID("Prpr"), stringIDToTypeID("layerID"));
    ref.putIndex(charIDToTypeID("Lyr "), idx);
    return executeActionGet(ref).getInteger(stringIDToTypeID("layerID"));
}

// returns array of selected layer IDs (handles multi-select; falls back to active layer)
function cpx_selectedIDs(){
    var ids = [];
    var ref = new ActionReference();
    ref.putProperty(charIDToTypeID("Prpr"), stringIDToTypeID("targetLayers"));
    ref.putEnumerated(charIDToTypeID("Dcmn"), charIDToTypeID("Ordn"), charIDToTypeID("Trgt"));
    var desc = executeActionGet(ref);
    if (desc.hasKey(stringIDToTypeID("targetLayers"))){
        var list = desc.getList(stringIDToTypeID("targetLayers"));
        var bg = cpx_hasBackground();
        for (var i = 0; i < list.count; i++){
            var idx = list.getReference(i).getIndex();
            // when there is NO background layer, layer indices are 1-based for AM
            ids.push(cpx_layerIDByIndex(idx + (bg ? 0 : 1)));
        }
    } else {
        // single layer selected -> read its id directly
        try {
            var r2 = new ActionReference();
            r2.putProperty(charIDToTypeID("Prpr"), stringIDToTypeID("layerID"));
            r2.putEnumerated(charIDToTypeID("Lyr "), charIDToTypeID("Ordn"), charIDToTypeID("Trgt"));
            ids.push(executeActionGet(r2).getInteger(stringIDToTypeID("layerID")));
        } catch (e) {}
    }
    return ids;
}

function cpx_getNameByID(id){
    var ref = new ActionReference();
    ref.putProperty(charIDToTypeID("Prpr"), charIDToTypeID("Nm  "));
    ref.putIdentifier(charIDToTypeID("Lyr "), id);
    return executeActionGet(ref).getString(charIDToTypeID("Nm  "));
}

function cpx_setNameByID(id, newName){
    var ref = new ActionReference();
    ref.putIdentifier(charIDToTypeID("Lyr "), id);
    var desc = new ActionDescriptor();
    desc.putReference(charIDToTypeID("null"), ref);
    var d2 = new ActionDescriptor();
    d2.putString(charIDToTypeID("Nm  "), newName);
    desc.putObject(charIDToTypeID("T   "), charIDToTypeID("Lyr "), d2);
    executeAction(charIDToTypeID("setd"), desc, DialogModes.NO);
}

// MAIN entry called from the panel. prefix: e.g. 'btn_', '' (clear), '//', '!'.
// replace: whether to strip an existing prefix first (default true).
function cpx_apply(prefix, replace){
    if (replace === undefined) replace = true;
    if (!app.documents.length) return 'ERR:no document';
    var ids = cpx_selectedIDs();
    if (!ids.length) return 'ERR:no layer selected';
    var n = 0;
    try {
        for (var i = 0; i < ids.length; i++){
            var cur = cpx_getNameByID(ids[i]);
            var nn  = cpx_newName(cur, prefix, replace);
            if (nn !== cur){ cpx_setNameByID(ids[i], nn); }
            n++;
        }
    } catch (e) {
        return 'ERR:' + e.toString();
    }
    return 'OK:' + n;
}
