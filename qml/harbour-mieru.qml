import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    property bool debugOn: true
    property bool requestLock: false
    property bool toReloadAccounts: true
    property int leftPadding: 25

    property bool showR18: true
    property bool loadSample: false

    property var faultsTags: []

    property string currentSite: ''
    property string currentUsername: ''
    property string currentPasshash: ''

    property string currentThumb: ''

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}

