.pragma library

.import "./storage.js" as Storage

var db = Storage.db;

function findReads(domain, username, tags, page_begin, page_end) {
    var reads = []
    if (!username) { return reads }
    if (!tags) { tags = '--any--' }
    db.transaction(function(tx) {
        var results = tx.executeSql("SELECT * FROM reads WHERE domain=? AND username=? AND tags=? AND begin>=? AND end<=?;", [domain, username, tags, page_end, page_begin])
        for (var i = 0; i < results.rows.length; i++) {
            reads.push(results.rows.item(i));
        }
    });
    return reads;
}

function markReads(domain, username, tags, begin, end) {
    var result = false;
    if (!username) { return }
    if (!tags) { tags = '--any--' }
    db.transaction(function(tx) {
        try {
            tx.executeSql("DELETE FROM reads WHERE domain=? AND username=? AND tags=? AND begin>=? AND end<=?;", [domain, username, tags, end, begin]);
            tx.executeSql("INSERT INTO reads (domain, username, tags, begin, end) VALUES (?, ?, ?, ?, ?);", [domain, username, tags, begin, end]);
            tx.executeSql("COMMIT;");
            result = true;
        } catch (err) {
            console.error("Error updating from table reads:", err);
            result = false;
        }
    });
    return result;
}

function findAll() {
    var reads = []
    db.transaction(function(tx) {
        var results = tx.executeSql("SELECT * FROM reads;")
        for (var i = 0; i < results.rows.length; i++) {
            reads.push(results.rows.item(i));
        }
    });
    return reads;
}

