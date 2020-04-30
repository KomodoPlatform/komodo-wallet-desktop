import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Constants"

Item {
    property alias inner_space: inner_space
    property alias content: inner_space.sourceComponent

    width: inner_space.width
    height: inner_space.height

    Rectangle {
        id: rect
        anchors.fill: parent
        radius: Style.rectangleCornerRadius
        color: Style.colorTheme7

        Loader {
            anchors.centerIn: parent
            id: inner_space
        }
    }

    DropShadow {
        anchors.fill: rect
        source: rect
        cached: false
        horizontalOffset: -6
        verticalOffset: -6
        radius: 15
        samples: 32
        spread: 0
        color: Style.colorDropShadowLight
        smooth: true
    }

    DropShadow {
        anchors.fill: rect
        source: rect
        cached: false
        horizontalOffset: 6
        verticalOffset: 6
        radius: 20
        samples: 32
        spread: 0
        color: Style.colorDropShadowDark
        smooth: true
    }
}


