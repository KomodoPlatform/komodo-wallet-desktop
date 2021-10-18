import QtQuick 2.12

import Dex.Themes 1.0 as Dex

Text
{
    id: root

    property alias hoverEnabled:  _mouseArea.hoverEnabled
    property alias containsMouse: _mouseArea.containsMouse

    signal clicked()

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    color: Dex.CurrentTheme.foregroundColor

    MouseArea
    {
        id: _mouseArea

        anchors.fill: parent
        onClicked: root.clicked();
    }
}
