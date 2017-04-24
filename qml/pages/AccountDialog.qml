import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/sites.js" as Sites
import "../js/accounts.js" as Accounts


Dialog {
    id: accountDialog

    property string domain: ''
    property string username: ''
    property string password: ''

    property bool anonymous: false

    property var sites: Sites.findAll()

    Column {
        width: parent.width

        DialogHeader {
            title: qsTr("New Account")
        }

        SectionHeader {
            text: qsTr("Site")
        }

        // TODO
        TextField {
            id: domainField
            width: parent.width - Theme.paddingLarge
            text: domain
            label: qsTr("Site URL")
            placeholderText: "https://yande.re"
        }

        SectionHeader {
            text: qsTr("Account")
        }

        TextField {
            id: usernameField
            width: parent.width - Theme.paddingLarge
            readOnly: anonymous
            text: username
            label: qsTr("Username (optional)")
            placeholderText: label
            inputMethodHints: Qt.ImhNoAutoUppercase
        }

        TextField {
            id: passwordField
            width: parent.width - Theme.paddingLarge
            readOnly: anonymous
            echoMode: TextInput.PasswordEchoOnEdit
            label: qsTr("Password (optional)")
            placeholderText: password ? "Password (unchanged)" : label
        }

        TextSwitch {
            id: anonymousSwitch
            text: qsTr("Anonymous")
            checked: anonymous
            onCheckedChanged: {
                if (checked) {
                    usernameField.text = '';
                    passwordField.text = '';
                } else {
                    usernameField.text = username;
                }
            }
        }

    }

    onAccepted: {
        if (domain !== domainField.text || username !== usernameField.text || passwordField.text) {
            domain = domainField.text;
            username = usernameField.text;
            password = passwordField.text;
            var result = Accounts.saveAccount(domain, username, password);
            if (!result) console.log("Failed to save account", domain, username);
        }
    }
}
