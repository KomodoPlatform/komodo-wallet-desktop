import QtQuick 2.15
import QtQuick.Controls 2.15

import App 1.0

ScrollBar {
    id: control

    anchors.right: root.right
    anchors.rightMargin: 3
    policy: scrollbar_visible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    property bool visibleBackground: true
    width: 10
    contentItem: Item {
        DexRectangle {
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            color: DexTheme.portfolioPieGradient ? DexTheme.buttonColorHovered : DexTheme.backgroundDarkColor7
        }
    }

    background: Item {
        width: 10
        x: 0
        DexRectangle {
            visible: control.visibleBackground
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

        }
    }
}