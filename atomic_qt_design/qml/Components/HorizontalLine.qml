import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

Rectangle {
    height: 2
    property bool light: false

    // Gradient
    LinearGradient {
        anchors.fill: parent
        source: parent
        start: Qt.point(0, 0)
        end: Qt.point(0, parent.height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: light ? Style.colorLineGradient3 : Style.colorLineGradient2 }
            GradientStop { position: 1.0; color: light ? Style.colorLineGradient4 : Style.colorLineGradient1 }
        }
    }
}
