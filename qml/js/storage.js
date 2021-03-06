.pragma library

.import QtQuick.LocalStorage 2.0 as LS


var identifier = "harbour-mieru";
var description = "Mieru Database";
var db_version = "2.3"

console.log("db loading")

var QUERY = {
    CREATE_SETTINGS_TABLE: 'CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT);',
    CREATE_SITES_TABLE: 'CREATE TABLE IF NOT EXISTS sites(domain TEXT PRIMARY KEY, url TEXT, name TEXT, hash_string TEXT);',
    CREATE_ACCOUNTS_TABLE: 'CREATE TABLE IF NOT EXISTS accounts(domain TEXT, username TEXT, passhash TEXT, remember INTEGER, is_active INTEGER, PRIMARY KEY(domain, username));',
    CREATE_READS_TABLE: 'CREATE TABLE IF NOT EXISTS reads(id INTEGER PRIMARY KEY, domain TEXT NOT NULL, username TEXT NOT NULL, tags TEXT, begin INTEGER, end INTEGER);'
}

/**
 * Create tables
 */
function _createTables(tx) {
    console.log("creating tables")
    tx.executeSql(QUERY.CREATE_SETTINGS_TABLE);
    tx.executeSql(QUERY.CREATE_SITES_TABLE);
    tx.executeSql(QUERY.CREATE_ACCOUNTS_TABLE);
    tx.executeSql(QUERY.CREATE_READS_TABLE);
}

/**
 * Open app's database, create it if not exists.
 */
var db = LS.LocalStorage.openDatabaseSync(identifier, "", description, 1000000, function(db) {
    console.log("db creating", db_version)
    db.changeVersion(db.version, db_version, function(tx) {
        _createTables(tx);
    });
});

// Check db version
if (db.version !== db_version) {
    db.changeVersion(db.version, db_version, function(tx) {
        console.log("upgrading db to version:", db.version, db_version)
        tx.executeSql("DROP TABLE IF EXISTS reads;");
        tx.executeSql(QUERY.CREATE_READS_TABLE);
    });
}

/**
 * Reset database
 */
function reset() {
    db.transaction(function(tx) {
        console.log("reseting tables")
        tx.executeSql("DROP TABLE IF EXISTS settings;");
        tx.executeSql("DROP TABLE IF EXISTS sites;");
        tx.executeSql("DROP TABLE IF EXISTS accounts;");
        tx.executeSql("DROP TABLE IF EXISTS reads;");
        _createTables(tx);
        tx.executeSql("COMMIT;");
    });
}

/**
 * Read one row
 */
function read(table, columnName, matchValue) {
    var results;
    db.transaction(function(tx){
        var query = "SELECT * FROM " + table + " WHERE " + columnName + " = ?;";
        results = tx.executeSql(query, [matchValue]);
    });
    return results.rows || [];
}

/**
 * Write one row
 */
function write(table, columnName, writeValue) {
    db.transaction(function(tx) {
        tx.executeSql("INSERT OR REPLACE INTO ? VALUES (?, ?);", [table, columnName, writeValue]);
        tx.executeSql("COMMIT;");
    });
}

