import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/booru.js" as Booru

Page {
    id: postPage

    property string workID: ''

    property var work: {}

    property string fromTags: ''
    property string siteName: '?'

    property bool faved: false

    property int currentIndex: -1

    property bool downloadable: Boolean(requestMgr)

    ListModel { id: tagsModel }
    ListModel { id: familyModel }


    function download() {
        if (requestMgr && downloadsModel && work['large']) {
            var img_url = work['large']
            var save_path = '/home/nemo/Pictures/'
            var filename = currentDomain + '_' + work['workID'] + img_url.substr(img_url.lastIndexOf('.'))
            // TODO ignore token
            requestMgr.saveImage('any', img_url, save_path, filename, 0)
            downloadsModel.append({
                filename: filename,
                path: save_path,
                source: img_url,
                thumb: work['preview'],
                finished: 0
            })
        }
    }

    function setTagTypes() {
        for (var i = 0; i < tagsModel.count; i++) {
            (function(tag) {
                Booru.getTags(currentSite, 0, 1, tag.tag, '', 'date', function(_tags) {
                    if (_tags.length > 0) {
                        for (var j = 0; j < _tags.length; j++) {
                            if (_tags[j].name === tag.tag) {
                                tag.typeId = _tags[j].type;
                            }
                        }
                    }
                }, 1);
            })(tagsModel.get(i))
        }
    }

    function findMe(resp) {
        var favedUsers = resp['favorited_users'];
        if (favedUsers) {
            if (favedUsers.split(",").indexOf(currentUsername) >= 0) {
                faved = true;
            } else {
                faved = false;
            }
        }
    }

    function getFavedUsers() {
        Booru.listFavedUsers(currentSite, workID, findMe);
    }

    function toggleVote() {
        var score = 3;
        if (faved) score = 2;

        Booru.vote(currentSite, currentUsername, currentPasshash, workID, score, function(resp) {
            if (score > 2)
                faved = true;
            else
                faved = false;
        });
    }

    SilicaFlickable {
        id: detailFlickable
        contentHeight: column.height + 200

        anchors.fill: parent

        PageHeader {
            id: pageHeader
            width: parent.width
            title: (faved ? "★ " : "☆ ") + work.headerText
        }

        PushUpMenu {
            id: pushUpMenu
            MenuItem {
                id: openWebViewAction
                text: qsTr("Open Web Page")
                onClicked: {
                    var postUrl = currentSite + "/post/show/" + workID
//                    var _props = {"initUrl":  postUrl}
//                    pageStack.push('WebViewPage.qml', _props)
                    Qt.openUrlExternally(postUrl);
                }
            }
        }

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                visible: downloadable
                id: dlAction
                text: qsTr("Download")
                onClicked: download()
            }
            MenuItem {
                visible: currentUsername
                id: voteAction
                text: faved ? qsTr("Unlike") : qsTr("Like")
                onClicked: toggleVote()
            }
        }

        Item {
            id: column
            width: parent.width
            height: childrenRect.height
            anchors.top: pageHeader.bottom

            Image {
                id: image
                width: parent.width - leftPadding*2
                anchors.horizontalCenter: parent.horizontalCenter

                fillMode: Image.PreserveAspectFit
                source: work.sample

                BusyIndicator {
                    anchors.centerIn: parent
                    running: image.status === Image.Loading
                }
            }

            Label {
                id: authorName
                width: parent.width - leftPadding*2
                anchors.top: image.bottom
                anchors.topMargin: Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryColor
                text: qsTr("Uploaded by: ") + work.authorName
                elide: TruncationMode.Elide
            }

            Label {
                id: caption
                width: parent.width - leftPadding*2
                anchors.top: authorName.bottom
                anchors.topMargin: Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
                color: Theme.primaryColor
                text: {
                    if (debugOn) console.log('source:'+work.source+':')
                    if (work.source.indexOf('http') === 0) {
                        return 'Source: <a href="' + work.source + '">' +
                                work.source.replace(/&/g, '&amp;') + '</a>'
                    } else if (work.source !== '') {
                        return 'Source: ' + work.source
                    } else {
                        return ''
                    }
                }
            }

            Label {
                id: updateTime
                width: parent.width - leftPadding*2
                anchors.top: caption.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignRight
                color: Theme.secondaryColor
                text: {
                    var t = new Date(work.createdAt*1000)
                    return t.toISOString().replace('T',' ').substr(0,19)
                }
            }

            ListView {
                id: familyList
                anchors.top: updateTime.bottom
                anchors.topMargin: 10
                width: parent.width
                height: childrenRect.height

                model: familyModel
                delegate: ListItem {
                    height: Theme.itemSizeSmall
                    width: parent.width
                    Label {
                        width: parent.width
                        anchors {
                            left: parent.left
                            leftMargin: leftPadding
                            verticalCenter: parent.verticalCenter
                        }
                        text: title
                    }
                    onClicked: {
                        var _props =  {
                            siteName: siteName,
                            searchTags: "parent:" + searchID,
                            fromBooruId: 0
                        };
                        pageStack.push("ListPage.qml", _props);
                    }
                }
            }

            ListView {
                id: tagsList
                anchors.top: familyList.bottom
                anchors.topMargin: 10
                width: parent.width
                height: childrenRect.height

                model: tagsModel
                delegate: ListItem {
                    width: parent.width
                    height: Theme.itemSizeSmall
                    Label {
                        width: parent.width - leftPadding*2
                        anchors.centerIn: parent
                        color: switch (typeId) {    // Yande.re style
                               case 6:   // Faults
                                   return '#FF2020';
                               case 5:   // Circle
                                   return '#00BBBB';
                               case 4:   // Character
                                   return '#00AA00'
                               case 3:   // Copyright
                                   return '#DD00DD';
                               case 1:   // Artist
                                   return '#CCCC00';
                               case 2:   // Unused
                               case 0:   // General
                               default:
                                   return Theme.secondaryHighlightColor;
                               }

                        text: tag
                    }
                    onClicked: {
                        if (debugOn) console.log('tag clicked', tag);
                        if (tag === fromTags) {
                            if (debugOn) console.log('pop back to same tag')
                            pageStack.pop()
                        } else {
                            pageStack.push("ListPage.qml", {
                                               siteName: siteName,
                                               searchTags: tag,
                                               fromBooruId: workID
                                           });
                        }
                    }
                }
            }
        }

    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (debugOn) console.log("detail page actived: " + workID)

            // Set cover image
            if (work && work.preview) {
                currentThumb = work.preview
            }
        }

        if (status === PageStatus.Inactive) {
            currentThumb = ""
        }

    }

    Component.onCompleted: {
        if (debugOn) console.log("details onCompleted")

        var tags = work.tags.split(' ')
        tagsModel.clear()
        for (var i in tags) {
            tagsModel.append( { tag: tags[i], typeId: 0 } )
        }

        if (work['parentID']) {
            familyModel.append({ title: "Parent " + work['parentID'], searchID: work['parentID'] });
        }
        if (work['hasChildren']) {
            familyModel.append({ title: "View children", searchID: work['workID'] });
        }

        getFavedUsers();

        setTagTypes();
    }
}

