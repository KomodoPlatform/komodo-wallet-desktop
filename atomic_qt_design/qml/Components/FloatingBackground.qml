import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

Item {
    property alias rect: rect
    property alias color: rect.color
    property alias radius: rect.radius
    property alias border: rect.border
    property alias inner_space: inner_space
    property alias content: inner_space.sourceComponent
    property alias mask: mask.sourceComponent
    property bool verticalShadow: false

    width: inner_space.width
    height: inner_space.height

    DefaultRectangle {
        id: rect
        anchors.fill: parent
        border.color: Style.colorBorder2

        Loader {
            anchors.centerIn: parent
            id: inner_space
        }

        visible: false
    }

    Loader {
        id: mask
        anchors.fill: rect
    }

    DropShadow {
        anchors.fill: mask.sourceComponent ? mask : rect
        source: mask.sourceComponent ? mask : rect
        cached: false
        horizontalOffset: verticalShadow ? 0 : -6
        verticalOffset: verticalShadow ? -10 : -6
        radius: verticalShadow ? 25 : 15
        samples: 32
        spread: 0
        color: verticalShadow ? Style.colorDropShadowLight2 : Style.colorDropShadowLight
        smooth: true
    }

    DropShadow {
        anchors.fill: mask.sourceComponent ? mask : rect
        source: mask.sourceComponent ? mask : rect
        cached: false
        horizontalOffset: verticalShadow ? 0 : 6
        verticalOffset: verticalShadow ? 10 : 6
        radius: verticalShadow ? 25 : 20
        samples: 32
        spread: 0
        color: Style.colorDropShadowDark
        smooth: true
    }
}


