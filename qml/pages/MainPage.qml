import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/accounts.js" as Accounts

Page {
    id: mainPage

    property var accounts: Accounts.findAll()

    ListModel { id: accountsModel }

    Component {
        id: accountRemovalDialog
        Dialog {
            property string domain: ''
            property string username: ''
            Column {
                width: parent.width
                DialogHeader {
                    title: qsTr("Remove account %1 ?").arg(username)
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: leftPadding
                    width: parent.width - 2 * leftPadding
                    text: qsTr("This is a [%1] account.").arg(domain)
                    wrapMode: Text.WordWrap
                }
            }
            onAccepted: {
                Accounts.removeAccount(domain, username);
                reloadAccounts();
            }
        }
    }

    SilicaFlickable {
        id: mainView

        anchors.fill: parent

        PageHeader {
            id: pageHeader
            title: qsTr("Moeru")
        }

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                text: "Settings"
                onClicked: {
                    pageStack.push("SettingsPage.qml")
                }
            }
            MenuItem {
                text: "Add account"
                onClicked: {
                    pageStack.push("AccountDialog.qml")
                }
            }
        }

        Label {
            anchors.centerIn: parent
            color: Theme.secondaryColor
            visible: accounts.length === 0
            text: "Pull to add an account"
        }

        ListView {
            anchors.top: pageHeader.bottom
            width: parent.width
            height: childrenRect.height
            model: accountsModel
            delegate: ListItem {
                Label {
                    //color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    anchors.centerIn: parent
                    text: domain + ": " + username.replace('--anonymous--', 'Anonymous')
                }
                onClicked: {
                    pageStack.push("ListPage.qml", { domain: domain, username: username });
                }
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Edit")
                        onClicked: {
                            var _username = username;
                            var anonymous = false;
                            if (username === '--anonymous--') {
                                _username = '';
                                anonymous = true;
                            }
                            pageStack.push('AccountDialog.qml', {domain: domain, username: _username, anonymous: anonymous});
                        }
                    }
                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: pageStack.push(accountRemovalDialog, {domain: domain, username: username});
                    }
                }
            }
        }
    }

    function reloadAccounts() {
        var accounts = Accounts.findAll(true);
        accountsModel.clear();
        for (var i = 0; i < accounts.length; i++) {
            accountsModel.append(accounts[i]);
            if (debugOn) console.log('found account:', JSON.stringify(accounts[i]));
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active && toReloadAccounts) {
            if (debugOn) console.log('reloading accounts');
            reloadAccounts();
            toReloadAccounts = false;
        }
    }
}
