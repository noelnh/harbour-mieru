.pragma library

function sendRequest(method, url, params, data, callback) {

    console.log(method, url, '[params]', data);

    var xmlhttp = new XMLHttpRequest();

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState === 4) {
            if (xmlhttp.status === 200) {
                console.log('success');
                callback(JSON.parse(xmlhttp.responseText));
            } else {
                console.log('failed');
            }
        }
    }

    if (params) url += '?' + params;

    xmlhttp.open(method, url);
    if (method === 'GET' || method === 'DELETE') {
        xmlhttp.send();
    } else if (method === 'POST') {
        xmlhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        xmlhttp.send(data);
    }
}

function getPosts(site, limit, page, tags, callback) {
    limit = limit || 50;
    page = page || 1;
    tags = tags || '';
    var params = 'limit=' + limit + '&page=' + page + '&tags=' + tags;
    var url = site + '/post.json';
    sendRequest('GET', url, params, '', callback);
}

function listFavedUsers(site, postID, callback) {
    var url = site + '/favorite/list_users.json';
    var params = 'id=' + postID;
    sendRequest('GET', url, params, '', callback);
}

function vote(site, username, passhash, postID, score, callback) {
    var url = site + "/post/vote.json";
    var params = "login=" + username + "&password_hash=" + passhash;
    var data = "id=" + postID + "&score=" + score;

    sendRequest('POST', url, params, data, callback);
}

function getTags(site, limit, page, tagName, type, order, callback, cache) {
    limit = limit || 50;
    page = page || 1;
    order = order || "date";

    var url = site + "/tag.json";
    var params = 'limit=' + limit + '&page=' + page + '&name=' +
            tagName + '&type=' + type + '&order=' + order;
    if (cache) {
        params = 'cache=1&' + params;
    }

    sendRequest('GET', url, params, '', callback)
}
