import QtQuick 2.15
import QtQuick.Controls 2.15

import "Screens"
import "Constants"

ApplicationWindow {
    id: window
    visible: true
    width: General.width
    height: General.height
    minimumWidth: General.minimumWidth
    minimumHeight: General.minimumHeight
    title: API.app.settings_pg.empty_string + (qsTr("atomicDEX Pro"))
    flags: Qt.Window | Qt.WindowFullscreenButtonHint

    Component.onCompleted: showMaximized()

    property int true_visibility

    onVisibilityChanged: {
        // 3 is minimized, ignore that
        if(visibility !== 3)
            true_visibility = visibility

        API.app.change_state(visibility)
    }

    App {
        anchors.fill: parent
    }
}
