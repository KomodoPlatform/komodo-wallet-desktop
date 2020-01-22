import QtQuick 2.12
import QtQuick.Window 2.12
import "Screens"
import "Constants"

Window {
    id: window
    visible: true
    width: General.width
    height: General.height
    title: qsTr("atomicDEX")
    flags: Qt.Window | Qt.WindowMaximizeButtonHint | Qt.WindowFullscreenButtonHint
    onVisibilityChanged: API.app().change_state(visibility)
    App {
        anchors.fill: parent
    }
}
