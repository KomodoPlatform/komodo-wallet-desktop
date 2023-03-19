import QtQuick 2.15
import QtQuick.Controls 2.15

import App 1.0
import Dex.Themes 1.0 as Dex


ScrollBar
{
    id: control

    anchors.right: root.right
    anchors.rightMargin: 0
    policy: scrollbar_visible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    property bool visibleBackground: true
    width: 6

    contentItem: Item
    {
        DexRectangle
        {
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            color: Dex.CurrentTheme.scrollBarIndicatorColor
        }
    }

    background: Item
    {
        width: 6
        DexRectangle
        {
            visible: control.visibleBackground
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            color: Dex.CurrentTheme.scrollBarBackgroundColor
        }
    }
}
