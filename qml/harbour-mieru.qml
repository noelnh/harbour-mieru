import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    property string appName: "harbour-mieru"

    property bool debugOn: true
    property bool requestLock: false
    property bool toReloadAccounts: true

    property bool showR18: false
    property bool loadSample: false

    property string currentDomain: ''
    property string currentSite: ''
    property string currentUsername: ''
    property string currentPasshash: ''

    property string currentThumb: ''

    property bool openPxvDetails: false
    property bool requestMgr: false

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}

