import QtQuick 2.15
import QtQuick.Controls 2.15

import Dex.Themes 1.0 as Dex

ScrollView
{
    id: control

    clip: true
    ScrollBar.vertical.background: Rectangle { color: Dex.CurrentTheme.scrollBarBackgroundColor; radius: 8 }
    ScrollBar.vertical.contentItem: Rectangle
    {
        implicitWidth: 10
        implicitHeight: 20
        color: Dex.CurrentTheme.scrollBarIndicatorColor
        radius: 8
    }
    ScrollBar.vertical.policy: contentHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    ScrollBar.horizontal.background: Rectangle { color: Dex.CurrentTheme.scrollBarBackgroundColor; radius: 8 }
    ScrollBar.horizontal.contentItem: Rectangle
    {
        implicitWidth: 20
        implicitHeight: 10
        color: Dex.CurrentTheme.scrollBarIndicatorColor
        radius: 8
    }
    ScrollBar.horizontal.policy: contentHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
}
