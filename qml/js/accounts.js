.pragma library

.import "./storage.js" as Storage

var db = Storage.db;

/**
 * Save an account
 */
function saveAccount(domain, username, password) {
    console.log("Reading hash string", domain);
    var hash_string = '';
    var sites = read('sites', 'domain', domain);
    if (sites.length > 0) {
        var site = sites.item(0);
        if (site) {
            hash_string = site.hash_string;
        }
    }
    if (!hash_string) {
        return false;
    }

    console.log("Adding account", domain, username);
    var passhash = utils.sha1(hash_string.replace('your-password', password));

    db.transaction(function(tx) {
        tx.executeSql("INSERT OR REPLACE INTO accounts VALUES (?, ?, ?, ?);", [domain, username, passhash, 1, 1]);
        tx.executeSql("COMMIT;");
    });

    return true;
}

/**
 * Remove an account
 */
function removeAccount(domain, username) {
    console.log("Removing an account", domain, username);
    var result = false;
    db.transaction(function(tx) {
        try {
            tx.executeSql("DELETE FROM accounts WHERE domain = ? AND username=?;", [domain, username]);
            tx.executeSql("COMMIT;");
            result = true;
        } catch (err) {
            console.error("Error deleting from table accounts:", err);
            result = false;
        }
    });
    return result;
}


/**
 * Find all accounts
 */
function findAll(onSingle, callBefore, callAfter, is_active) {
    if (typeof is_active === 'undefined') {
        is_active = 1;
    }

    db.readTransaction(function(tx) {
        var results = tx.executeSql("SELECT * FROM accounts WHERE is_active = ?;", [is_active]);
        var len = results.rows.length;

        if (typeof callBefore === "function") {
            callBefore();
        }

        if (typeof onSingle === "function") {
            for (var i = 0; i < len; i++) {
                onSingle(results.rows.item(i));
            }
        }

        if (typeof callAfter === "function") {
            var accounts = [];
            for (var i = 0; i < len; i++) {
                accounts.push(results.rows.item(i));
            }
            callAfter(accounts);
        }

    });
}

/**
 * Find account by domain & username
 */
function find(domain, username) {
    var account = null;
    db.readTransaction(function(tx) {
        var query = "SELECT * FROM accounts WHERE domain = ? AND username = ?;";
        var results = tx.executeSql(query, [domain, username]);

        if (results.rows.length !== 1) {
            console.error("Found 0 or more than one account:", results.rows.length);
            account = null;
        } else {
            account = results.rows.item(0);
        }
    });
    return account;
}

