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
TARGET = harbour-chessgoclock

QT += dbus

DISTFILES += qml/harbour-chessgoclock.qml \
    qml/cover/CoverPage.qml \
    qml/pages/Clocks.qml \
    qml/pages/ColorGrid.qml \
    qml/pages/ColorSelection.qml \
    qml/pages/deleteSettings.qml \
    qml/pages/info.qml \
    qml/pages/saveSettings.qml \
    qml/pages/TimeSettings.qml \
    rpm/harbour-chessgoclock.changes.in \
    rpm/harbour-chessgoclock.changes.run.in \
    rpm/harbour-chessgoclock.spec \
    rpm/harbour-chessgoclock.yaml \
    translations/*.ts \
    harbour-chessgoclock.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

CONFIG += sailfishapp_qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-chessgoclock-fi.ts
