# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-moeru

CONFIG += sailfishapp

SOURCES += src/harbour-moeru.cpp \
    src/utils.cpp

OTHER_FILES += qml/harbour-moeru.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-moeru.changes.in \
    rpm/harbour-moeru.spec \
    rpm/harbour-moeru.yaml \
    translations/*.ts \
    harbour-moeru.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-moeru-de.ts

DISTFILES += \
    qml/pages/MainPage.qml \
    qml/pages/ListPage.qml \
    qml/pages/PostPage.qml \
    qml/pages/SettingsPage.qml \
    qml/js/booru.js \
    qml/pages/OptionsDialog.qml \
    qml/js/storage.js \
    qml/js/accounts.js \
    qml/pages/AccountDialog.qml \
    qml/js/sites.js \
    qml/js/settings.js \
    qml/pages/SiteDialog.qml

HEADERS += \
    src/utils.h
