import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0

import "../Constants"

// Gradient
LinearGradient {
    property alias start_pos: g_start.position
    property alias end_pos: g_end.position

    property color start_color: Style.colorGradient1
    property color end_color: Style.colorGradient2

    anchors.fill: parent
    anchors.margins: parent.border.width
    source: parent

    start: Qt.point(anchors.margins, anchors.margins)
    end: Qt.point(parent.width - anchors.margins, anchors.margins)

    gradient: Gradient {
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
