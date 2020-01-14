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

    App {
        anchors.fill: parent
    }
}
