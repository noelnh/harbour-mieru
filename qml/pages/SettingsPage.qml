import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage

    SilicaFlickable {
        id: settingsFlickable

        contentHeight: settingsColumn.height + Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: settingsColumn
            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Bebavior")
            }

            SectionHeader {
                text: qsTr("Downloads")
            }
        }
    }

}
