import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    property bool debugOn: true
    property bool requestLock: false
    property int leftPadding: 25

    property bool showR18: true

    initialPage: Component { ListPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}

