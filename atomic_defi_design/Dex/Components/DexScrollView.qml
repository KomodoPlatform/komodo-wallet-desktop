import QtQuick 2.15
import QtQuick.Controls 2.15

import Dex.Themes 1.0 as Dex

ScrollView
{
    id: control
    property bool h_scrollbar_visible: contentItem.childrenRect.width > width
    clip: true

    ScrollBar.vertical: DexScrollBar
    {
        property bool scrollbar_visible: contentItem.childrenRect.height > height
        anchors.rightMargin: 3
    }

    ScrollBar.horizontal: DexScrollBar
    {
        property bool scrollbar_visible: h_scrollbar_visible
        anchors.bottomMargin: 3
    }
}
