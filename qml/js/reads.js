.pragma library

.import "./storage.js" as Storage

var db = Storage.db;

function findReads(domain, username, page_begin, page_end) {
    var reads = []
    db.transaction(function(tx) {
        var results = tx.executeSql("SELECT * FROM reads WHERE domain=? AND username=? AND begin>=? AND end<=?;", [domain, username, page_end, page_begin])
        for (var i = 0; i < results.rows.length; i++) {
            reads.push(results.rows.item(i));
        }
    });
    return reads;
}

function markReads(domain, username, begin, end) {
    var result = false;
    db.transaction(function(tx) {
        try {
            tx.executeSql("DELETE FROM reads WHERE domain=? AND username=? AND begin>=? AND end<=?;", [domain, username, end, begin]);
            tx.executeSql("INSERT INTO reads (domain, username, begin, end) VALUES (?, ?, ?, ?);", [domain, username, begin, end]);
            tx.executeSql("COMMIT;");
            result = true;
        } catch (err) {
            console.error("Error updating from table reads:", err);
            result = false;
        }
    });
    return result;
}
