import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    CoverPlaceholder {
        id: coverHolder
        visible: !currentThumb
        icon.source: "../images/harbour-mieru.png"
        text: qsTr("Mieru")
    }

    Label {
        id: coverLabel
        width: parent.width
        visible: currentThumb
        anchors {
            bottom: coverImage.top
            bottomMargin: Theme.paddingLarge
        }
        horizontalAlignment: Text.AlignHCenter
        elide: TruncationMode.Fade
        text: qsTr("Mieru")
    }

    Image {
        id: coverImage
        anchors.centerIn: parent
        width: 180
        height: width
        fillMode: Image.PreserveAspectCrop
        source: currentThumb
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            //onTriggered: TODO
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            //onTriggered: TODO
        }
    }
}

