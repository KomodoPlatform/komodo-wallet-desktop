import QtQuick 2.15
import QtQuick.Controls 2.15

import App 1.0
import Dex.Themes 1.0 as Dex

ScrollBar
{
    id: control

    anchors.bottom: root.bottom
    anchors.bottomMargin: 0
    policy: scrollbar_visible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    property bool visibleBackground: true
    width: 6

    contentItem: Item
    {
        DefaultRectangle
        {
            width: parent.width
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            color: Dex.CurrentTheme.scrollBarIndicatorColor
        }
    }

    background: Item
    {
        width: 6
        x: 0
        DefaultRectangle
        {
            visible: control.visibleBackground
            width: parent.width
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: Dex.CurrentTheme.scrollBarBackgroundColor
        }
    }
}
