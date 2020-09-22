import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0

import "../Constants"

// Gradient
Rectangle {
    property alias orientation: gradient.orientation

    property alias start_pos: g_start.position
    property alias end_pos: g_end.position

    property color start_color: Style.colorGradient1
    property color end_color: Style.colorGradient2
    Behavior on start_color { ColorAnimation { duration: Style.animationDuration } }
    Behavior on end_color { ColorAnimation { duration: Style.animationDuration } }

    gradient: Gradient {
        id: gradient
        orientation: Qt.Horizontal

        GradientStop {
            id: g_start
            position: 0.0
            color: start_color
        }

        GradientStop {
            id: g_end
            position: 1.0
            color: end_color
        }
    }
}
