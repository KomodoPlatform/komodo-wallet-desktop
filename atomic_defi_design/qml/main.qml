import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial

import "Screens"
import "Constants"

Qaterial.ApplicationWindow {
    id: window
    visible: true
    minimumWidth: General.minimumWidth
    minimumHeight: General.minimumHeight
    title: qsTr("AtomicDEX Pro")
    flags: Qt.Window | Qt.WindowFullscreenButtonHint

    property int real_visibility

    Component.onCompleted: showMaximized()

    onVisibilityChanged: {
        // 3 is minimized, ignore that
        if(visibility !== 3)
            real_visibility = visibility

        API.app.change_state(visibility)
    }

    App {
        anchors.fill: parent
    }
}
