import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Constants"

ScrollBar {
    id: control

    anchors.right: root.right
    anchors.rightMargin: 3
    policy: scrollbar_visible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    property bool visibleBackground: true
    width: 6
    contentItem: Item {
        FloatingBackground {
            width: parent.width
            height: parent.height - 7 - 4
            anchors.verticalCenter: parent.verticalCenter

            color: Style.colorScrollbar
            border_color_start: Style.colorScrollbarGradient1
            border_color_end: Style.colorScrollbarGradient2
        }
    }

    background: Item {
        width: 10
        x: -width/2 + 6/2
        InnerBackground {
            visible: control.visibleBackground
            width: parent.width
            height: parent.height - 7
            anchors.verticalCenter: parent.verticalCenter

            color: Style.colorScrollbarBackground
        }
    }
}
