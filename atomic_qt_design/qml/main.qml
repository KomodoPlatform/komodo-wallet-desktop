import QtQuick 2.14
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
    title: API.get().settings_pg.empty_string + (qsTr("AtomicDeFi Pro"))
    flags: Qt.Window | Qt.WindowFullscreenButtonHint

    Component.onCompleted: showMaximized()

    property int true_visibility

    onVisibilityChanged: {
        // 3 is minimized, ignore that
        if(visibility !== 3)
            true_visibility = visibility

        API.get().change_state(visibility)
    }

    App {
        anchors.fill: parent
    }
}
