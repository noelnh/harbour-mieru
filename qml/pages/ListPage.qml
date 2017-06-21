import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/booru.js" as Booru
import "../js/sites.js" as Sites
import "../js/accounts.js" as Accounts

Page {
    id: listPage

    property int currentPage: 1
    property int currentIndex: -1
    property int pageSize: 40

    property string searchTags: ''

    property string fromBooruId: ''

    property int emptyFetch: 0

    property string domain: ''
    property string booruSite: '?'
    property string username: ''

    property int heightL: 0
    property int heightR: 0

    ListModel { id: booruModelL }
    ListModel { id: booruModelR }


    function generataPageStr() {
        return booruSite + "," + pageSize + "," + currentPage + "," + searchTags;
    }

    function reloadPostList(pageNum, _tags) {
        currentPage = pageNum || currentPage;
        searchTags = _tags || searchTags;
        booruModelL.clear();
        booruModelR.clear();
        emptyFetch = 0;
        Booru.getPosts(currentSite, pageSize, currentPage, searchTags, addBooruPosts);
    }

    function checkProtocol(prot, work) {
        var urlNames = ['preview_url', 'sample_url', 'file_url'];
        var urls = {};
        for (var i in urlNames) {
            var name = urlNames[i];
            var url = work[name];
            urls[name] = url.indexOf('//') === 0 ? prot + url : url;
        }
        return urls;
    }

    // Add posts to this model
    function addBooruPosts(works) {

        requestLock = false;

        if (!works) return;

        if (debugOn) console.log('adding posts to booruModel')

        var prot = 'http:';
        if (booruSite && booruSite.indexOf('https:') === 0) {
            prot = 'https:';
        }

        var validCount = 0;
        for (var i in works) {
            if (!showR18 && works[i]['rating'] !== 's') continue;
            var urls = checkProtocol(prot, works[i]);
            var elmt = {
                workID: works[i]['id'],
                parentID: works[i]['parent_id'],
                hasChildren: works[i]['has_children'],
                headerText: booruSite + ' ' + works[i]['id'],
                preview: urls['preview_url'],
                sample: urls['sample_url'],
                large: urls['file_url'],
                source: works[i]['source'],
                height_p: works[i]['actual_preview_height'] / works[i]['actual_preview_width'],
                authorID: works[i]['creator_id'],
                authorName: works[i]['author'],
                md5: works[i]['md5'],
                tags: works[i]['tags'],
                createdAt: works[i]['created_at']
            };
            if ( heightR >= heightL ) {
                elmt.column = 'L';
                booruModelL.append(elmt);
                heightL += elmt.height_p * 100;
                //if (debugOn) console.log('left +', 270 * elmt.height_p);
            } else {
                elmt.column = 'R';
                booruModelR.append(elmt);
                heightR += elmt.height_p * 100;
                //if (debugOn) console.log('right +', 270 * elmt.height_p);
            }
            validCount += 1;
        }
        if (emptyFetch < 2) {
            if (validCount === 0) {
                emptyFetch += 1;
                requestLock = true;
                currentPage += 1;
                Booru.getPosts(currentSite, pageSize, currentPage, searchTags, addBooruPosts);
            } else {
                emptyFetch = 0;
            }
        } else {
            infoBanner.showText("Cannot load posts...");
        }
    }

    function isPxvSource(url, shortMatch) {
        var _url = url;
        if (typeof url !== "string") _url = url.toString();
        if (shortMatch) return _url.indexOf('pixiv') > 0 || _url.indexOf('pximg') > 0;
        return _url.indexOf('pixiv.net/img-orig') > 0 || _url.indexOf('pximg.net/img-orig') > 0;
    }


    Component {
        id: booruDelegate

        ListItem {
            id: bitem
            width: parent.width
            contentHeight: width * height_p

            property var postSrc: source

            menu: ContextMenu {
                anchors.right: parent ? parent.right : undefined    // ContextMenu's parent: null -> ListItem
                MenuItem {
                    visible: currentUsername
                    text: qsTr("Like")
                    onClicked: {
                        console.log("Like post:", workID);
                        Booru.vote(currentSite, currentUsername, currentPasshash, workID, 3, function(resp) {});
                    }
                }
                MenuItem {
                    visible: currentUsername
                    text: qsTr("Unlike")
                    onClicked: {
                        console.log("Unlike post:", workID);
                        Booru.vote(currentSite, currentUsername, currentPasshash, workID, 2, function(resp) {});
                    }
                }
            }

            Image {
                id: image
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                source: preview

                Image {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    source: isPxvSource(postSrc, true) ? "https://source.pixiv.net/touch/touch/img/cmn/favicon.ico" : ""
                }
            }

            onClicked: {
                if (fromBooruId == workID) { // string == number
                    pageStack.pop()
                } else {
                    var _props = {
                        "workID": workID,
                        "currentIndex": index,
                        "fromTags": searchTags,
                        "booruSite": booruSite,
                        "work": column === 'L' ? booruModelL.get(index) : booruModelR.get(index)
                    }
                    pageStack.push("PostPage.qml", _props)
                }
            }
        }
    }

    SilicaFlickable {
        id: booruFlicableView

        contentHeight: header.height + (columnLeft.height > columnRight.height ? columnLeft.height : columnRight.height)
        anchors.fill: parent

        PageHeader {
            id: header
            title: booruSite + ": " + searchTags + " P" + currentPage
        }

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                text: qsTr("Refresh")
                onClicked: reloadPostList()
            }
            MenuItem {
                text: qsTr("Previous page")
                visible: currentPage > 1
                onClicked: {
                    if (!requestLock) {
                        requestLock = true;
                        reloadPostList(currentPage - 1);
                    }
                }
            }
        }

        PushUpMenu {
            id: pushUpMenu
            MenuItem {
                text: qsTr("Next page")
                onClicked: {
                    if (!requestLock) {
                        requestLock = true;
                        reloadPostList(currentPage + 1);
                    }
                }
            }
            MenuItem {
                text: qsTr("Go to page ...")
                onClicked: {
                    pageStack.navigateForward();
                }
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: requestLock || !(booruModelL.count + booruModelR.count)
        }

        ListView {
            id: columnLeft
            width: parent.width / 2
            height: childrenRect.height
            anchors.top: header.bottom
            anchors.left: parent.left

            model: booruModelL
            delegate: booruDelegate

        }

        ListView {
            id: columnRight
            width: parent.width / 2
            height: childrenRect.height
            anchors.top: header.bottom
            anchors.left: columnLeft.right

            model: booruModelR
            delegate: booruDelegate

        }

        onAtYEndChanged: {
        }

    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            pageStack.pushAttached("OptionsDialog.qml", {
                                       "_currentPage": currentPage,
                                       "_tags": searchTags
                                   });
        }
        if (status == PageStatus.Deactivating) {
            if (_navigation == PageNavigation.Back) {
                if (debugOn) console.log("navigated back")
            }
        }
    }

    Component.onCompleted: {
        var site = Sites.find(domain);
        if (site) {
            currentSite = site['url'];
            booruSite = site['name'];
        }
        if (username === '--anonymous--') {
            currentUsername = '';
            currentPasshash = '';
        } else {
            var user = Accounts.find(domain, username);
            if (user) {
                currentUsername = user['username'];
                currentPasshash = user['passhash'];
            }
        }

        if (booruModelR.count + booruModelL.count === 0) {
            currentPage = 1
            Booru.getPosts(currentSite, pageSize, currentPage, searchTags, addBooruPosts)
        }
    }
}
