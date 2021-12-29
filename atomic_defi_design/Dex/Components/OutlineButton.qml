import QtQuick 2.12

import Dex.Themes 1.0 as Dex

Rectangle
{
    property alias label: _label
    property alias text:  _label.text

    signal clicked()

    width: 200
    height: 48
    radius: 18

    gradient: Gradient
    {
        GradientStop
        {
            position: 0.5;
            color: enabled ? _mouseArea.containsMouse ? _mouseArea.containsPress ?
                    Dex.CurrentTheme.gradientButtonPressedStartColor :
                    Dex.CurrentTheme.gradientButtonHoveredStartColor :
                    Dex.CurrentTheme.gradientButtonStartColor :
                    Dex.CurrentTheme.gradientButtonDisabledStartColor
        }
        GradientStop
        {
            position: 0.8
            color: enabled ? _mouseArea.containsMouse ? _mouseArea.containsPress ?
                    Dex.CurrentTheme.gradientButtonPressedEndColor :
                    Dex.CurrentTheme.gradientButtonHoveredEndColor :
                    Dex.CurrentTheme.gradientButtonEndColor :
                    Dex.CurrentTheme.gradientButtonDisabledEndColor
        }
    }

    Rectangle
    {
        anchors.centerIn: parent
        width: parent.width - 6
        height: parent.height - 6
        radius: parent.radius - 3
        color: _mouseArea.containsMouse || _mouseArea.containsPress ? 'transparent' : Dex.CurrentTheme.backgroundColor
    }

    Text
    {
        id: _label
        anchors.centerIn: parent
        font.pixelSize: 16
        color: _mouseArea.containsMouse || _mouseArea.containsPress ? Dex.CurrentTheme.gradientButtonTextEnabledColor : Dex.CurrentTheme.foregroundColor
    }

    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: parent.clicked()
    }
}
