.pragma library

.import "./storage.js" as Storage

var db = Storage.db;

/**
 * Add a site
 */
function addSite(domain, url, name, hash_string) {
    var result = false;
    db.transaction(function(tx) {
        try {
            tx.executeSql("INSERT OR REPLACE INTO sites VALUES (?, ?, ?, ?);", [domain, url, name, hash_string]);
            tx.executeSql("COMMIT;");
            result = true;
        } catch (err) {
            console.error("Error adding to table sites:", err);
            result = false;
        }
    });
    return result;
}

/**
 * Remove a site
 */
function removeSite(domain) {
    console.log("Removing a site", domain);
    var result = false;
    db.transaction(function(tx) {
        try {
            tx.executeSql("DELETE FROM sites WHERE domain=?;", [domain]);
            tx.executeSql("COMMIT;");
            result = true;
        } catch (err) {
            console.error("Error deleting from table sites:", err);
            result = false;
        }
    });
    return result;
}

/**
 * Find all sites
 */
function findAll() {
    var accounts = [];
    db.readTransaction(function(tx) {
        var results = tx.executeSql("SELECT * FROM sites;");
        var len = results.rows.length;
        for (var i = 0; i < len; i++) {
            accounts.push(results.rows.item(i));
        }
    });
    return accounts;
}

