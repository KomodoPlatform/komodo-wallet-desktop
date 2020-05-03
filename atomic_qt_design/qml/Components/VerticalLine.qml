import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

Rectangle {
    width: 2

    // Gradient
    LinearGradient {
        anchors.fill: parent
        source: parent
        start: Qt.point(0, 0)
        end: Qt.point(parent.width, 0)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Style.colorLineGradient1 }
            GradientStop { position: 1.0; color: Style.colorLineGradient2 }
        }
    }
}
