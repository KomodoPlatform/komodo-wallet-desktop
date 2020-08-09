import QtQuick 2.12
import QtQuick.Window 2.12
import "Screens"
import "Constants"

Window {
    id: window
    visible: true
    width: General.width
    height: General.height
    minimumWidth: General.minimumWidth
    minimumHeight: General.minimumHeight
    title: API.get().settings_pg.empty_string + (qsTr("AtomicDEX Pro"))
    flags: Qt.Window | Qt.WindowFullscreenButtonHint

    Component.onCompleted: showMaximized()

    onVisibilityChanged: API.get().change_state(visibility)
    App {
        anchors.fill: parent
    }
}
