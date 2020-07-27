import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ScrollBar {
    id: control

    anchors.right: root.right
    anchors.rightMargin: Style.scrollbarOffset
    policy: scrollbar_visible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

    width: 6
    anchors.margins: 50
    contentItem: Item {
        FloatingBackground {
            width: parent.width
            height: parent.height - 14
            anchors.verticalCenter: parent.verticalCenter

            radius: 100

            color: Style.colorScrollbar
            border_color_start: Style.colorScrollbarGradient1
            border_color_end: Style.colorScrollbarGradient2
        }
    }

    background: Item {
        width: 10
        x: -width/2 + 6/2
        InnerBackground {
            width: parent.width
            height: parent.height - 10
            anchors.verticalCenter: parent.verticalCenter

            radius: 100
            color: Style.colorScrollbarBackground
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

