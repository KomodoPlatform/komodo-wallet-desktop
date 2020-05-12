import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

Item {
    id: root
    property alias rect: rect
    property alias color: rect.color
    property alias radius: rect.radius
    property alias border: rect.border
    property alias inner_space: inner_space
    property alias content: inner_space.sourceComponent
    property alias mask: mask_loader.sourceComponent
    property bool verticalShadow: false
    property bool opacity_mask_enabled: false

    readonly property var visible_rect: opacity_mask_enabled ? mask_loader : rect
    width: inner_space.width
    height: inner_space.height
    DefaultRectangle {
        id: rect
        anchors.fill: parent
        border.color: "transparent" //Style.colorBorder2

        Loader {
            anchors.centerIn: parent
            id: inner_space
        }

        visible: !opacity_mask_enabled
    }

    Loader {
        id: mask_loader
        anchors.fill: rect
    }

    LinearGradient {
        visible: rect.border.width > 0
        source: visible_rect
        width: parent.width + rect.border.width*2
        height: parent.height + rect.border.width*2
        anchors.centerIn: parent

        z: -1
        start: Qt.point(0, 0)
        end: Qt.point(width, height)

        gradient: Gradient {
            GradientStop {
               position: 0.35
               color: Style.colorRectangleBorderGradient1
            }
            GradientStop {
               position: 0.65
               color: Style.colorRectangleBorderGradient2
            }
        }
    }

    DropShadow {
        anchors.fill: visible_rect
        source: visible_rect
        cached: false
        horizontalOffset: verticalShadow ? 0 : -6
        verticalOffset: verticalShadow ? -10 : -6
        radius: verticalShadow ? 25 : 15
        samples: 32
        spread: 0
        color: verticalShadow ? Style.colorDropShadowLight2 : Style.colorDropShadowLight
        smooth: true
        z: -2
    }

    DropShadow {
        anchors.fill: visible_rect
        source: visible_rect
        cached: false
        horizontalOffset: verticalShadow ? 0 : 6
        verticalOffset: verticalShadow ? 10 : 6
        radius: verticalShadow ? 25 : 20
        samples: 32
        spread: 0
        color: Style.colorDropShadowDark
        smooth: true
        z: -2
    }
}


