import QtQuick 2.12

import Dex.Themes 1.0 as Dex

Text
{
    id: control

    property alias hoverEnabled:  _mouseArea.hoverEnabled
    property alias containsMouse: _mouseArea.containsMouse
    property alias containsPress: _mouseArea.containsPress

    signal clicked()

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    color: enabled ? _mouseArea.containsPress ?
                         Dex.CurrentTheme.buttonTextPressedColor : _mouseArea.containsMouse ?
                             Dex.CurrentTheme.buttonTextHoveredColor : Dex.CurrentTheme.foregroundColor :
           Dex.CurrentTheme.textDisabledColor

    MouseArea
    {
        id: _mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: control.clicked()
    }
}
