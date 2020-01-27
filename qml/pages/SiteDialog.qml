import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/sites.js" as Sites

Dialog {
    id: sitePage

    property string siteName: ''
    property string domain: ''
    property string prot: ''
    property string url: ''
    property string hashString: ''

    property var existingSites

    SilicaFlickable {
        contentHeight: siteColumn.height + Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: siteColumn
            width: parent.width

            DialogHeader {
                title: domain ? qsTr("Edit Site") : qsTr("New Site")
            }

            TextField {
                id: nameField
                width: parent.width - Theme.paddingLarge
                text: siteName
                label: qsTr("Site name (optional)")
                placeholderText: label
            }

            TextField {
                id: domainField
                readOnly: domain !== ''
                width: parent.width - Theme.paddingLarge
                text: domain
                label: qsTr("Site domain")
                placeholderText: label + ", e.g. example.com"
                inputMethodHints: Qt.ImhNoAutoUppercase
                onTextChanged: checkDupe(text)
            }

            Button {
                id: dupeButton
                text: qsTr("Replace Existing Site")
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    visible = false
                    canAccept = true
                }
            }

            TextField {
                id: urlField
                width: parent.width - Theme.paddingLarge
                text: prot + domainField.text
                label: qsTr("Site URL")
                placeholderText: "e.g. https://example.com"
                validator: RegExpValidator { regExp: /https?:\/\/.*[A-z]/ }
                onFocusChanged: {
                    if (text.indexOf('https://') === 0) {
                        prot = "https://"
                    } else if (text.indexOf('http://') === 0) {
                        prot = "http://"
                    }
                }
            }

            TextField {
                id: hashField
                width: parent.width - Theme.paddingLarge
                text: hashString || "change-me--your-password--"
                label: qsTr("Hash string, that can be found on " +
                            "\nhttp://somesite/help/api. " +
                            "\nThis is required to login your account.")
                placeholderText: "Hash string, e.g. change-me--your-password--"
            }
        }
    }

    Component.onCompleted: {
        if (!url || url.indexOf('https://') === 0) {
            prot = "https://"
        } else {
            prot = "http://"
        }
        if (url && url !== prot + domain) {
            urlField.text = url
        }
    }

    onAccepted: {
        domain = domainField.text;
        url = urlField.text;
        siteName = nameField.text || domain;
        hashString = hashField.text || 'change-me--your-password--';

        if (domain && url) {
            var result = Sites.addSite(domain, url, siteName, hashString);
            if (debugOn) console.log("add site:", domain, url, siteName, hashString, result);
        }
    }

    function checkDupe(domain) {
        if (!existingSites) {
            existingSites = Sites.findAll()
        }

        var found = false
        for (var i = 0; i < existingSites.length; i++) {
            if (existingSites[i].domain === domain) {
                found = true
                break
            }
        }

        if (found) {
            canAccept = false
            dupeButton.visible = true
        } else {
            canAccept = true
            dupeButton.visible = false
        }
    }
}
