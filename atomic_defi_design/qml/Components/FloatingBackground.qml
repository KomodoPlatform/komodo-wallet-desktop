import QtQuick 2.15
import QtGraphicalEffects 1.0
import "../Constants"
import App 1.0

Item {
    id: root
    property alias rect: rect
    property alias color: rect.color
    property double border_gradient_start_pos: 0.35
    property double border_gradient_end_pos: 0.65
    property color border_color_start: DexTheme.theme === "light" ? DexTheme.contentColorTopBold : DexTheme.colorInnerShadowTop
    property color border_color_end: DexTheme.theme === "light" ? DexTheme.contentColorTopBold : DexTheme.colorInnerShadowBottom
    property alias radius: rect.radius
    property alias border: rect.border
    property alias inner_space: inner_space
    property alias content: inner_space.sourceComponent
    property alias mask: mask_loader.sourceComponent
    property bool verticalShadow: false
    property bool opacity_mask_enabled: false
    property bool auto_set_size: true
    property bool show_shadow: true
    property alias light_gradient: _linear_gradient
    property alias black_shadow: _black_shadow
    property bool topShadowVisible: show_shadow 

    readonly property var visible_rect: opacity_mask_enabled ? mask_loader : rect

    implicitWidth: auto_set_size ? inner_space.width : 0
    implicitHeight: auto_set_size ? inner_space.height : 0

    DefaultRectangle {
        id: rect
        anchors.fill: parent
        border.color: DexTheme.contentColorTop

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
        id: _linear_gradient
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
               position: border_gradient_start_pos
               color: border_color_start
            }
            GradientStop {
               position: border_gradient_end_pos
               color: border_color_end
            }
        }
    }

    DropShadow {
        anchors.fill: visible_rect
        source: visible_rect
        cached: false
        visible: topShadowVisible
        horizontalOffset: verticalShadow ? 0 : -6
        verticalOffset: verticalShadow ? -10 : -6
        radius: verticalShadow ? 25 : 15
        samples: 32
        spread: 0
        color: verticalShadow ? DexTheme.floatShadow2 : DexTheme.floatShadow1
        smooth: true
        z: -2
    }

    DropShadow {
        id: _black_shadow
        anchors.fill: visible_rect
        source: visible_rect
        cached: false
        visible: show_shadow
        horizontalOffset: verticalShadow ? 0 : 6
        verticalOffset: verticalShadow ? 10 : 6
        radius: verticalShadow ? 25 : 20
        samples: 32
        spread: 0
        color: DexTheme.floatBoxShadowDark
        smooth: true
        z: -2
    }
}


