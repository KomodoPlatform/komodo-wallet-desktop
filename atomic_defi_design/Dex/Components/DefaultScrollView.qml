import QtQuick.Controls 2.15
import QtQuick 2.9

import Dex.Themes 1.0 as Dex

ScrollView
{
    id: control

    clip: true
    ScrollBar.vertical: ScrollBar
    {
        parent: control
        x: control.mirrored ? 0 : control.width - width
        y: control.topPadding
        height: control.availableHeight
        active: control.ScrollBar.horizontal.active

        contentItem: Rectangle
        {
            implicitWidth: 10
            implicitHeight: 20
            color: Dex.CurrentTheme.scrollBarIndicatorColor
            radius: 8
        }
        background: Rectangle { color: Dex.CurrentTheme.scrollBarBackgroundColor; radius: 8 }
    }
    ScrollBar.horizontal: ScrollBar
    {
        parent: control
        x: control.mirrored ? 0 : control.width - width
        y: control.topPadding
        width: control.availableWidth
        active: control.ScrollBar.vertical.active

        contentItem: Rectangle
        {
            implicitWidth: 20
            implicitHeight: 10
            color: Dex.CurrentTheme.scrollBarIndicatorColor
            radius: 8
        }
        background: Rectangle { color: Dex.CurrentTheme.scrollBarBackgroundColor; radius: 8 }
    }
}
