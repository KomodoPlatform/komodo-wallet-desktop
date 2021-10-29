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
        GradientStop { position: 0.5; color: Dex.CurrentTheme.gradientButtonStartColor }
        GradientStop { position: 0.8; color: Dex.CurrentTheme.gradientButtonEndColor }
    }

    Rectangle
    {
        anchors.centerIn: parent
        width: parent.width - 6
        height: parent.height - 6
        radius: parent.radius - 3
        color: _mouseArea.containsPress ?
                   Dex.CurrentTheme.backgroundColorDeep : _mouseArea.containsMouse ?
                       Dex.CurrentTheme.buttonColorHovered : Dex.CurrentTheme.backgroundColor
    }

    DefaultText
    {
        id: _label

        anchors.centerIn: parent

        font.pixelSize: 16
    }

    MouseArea
    {
        id: _mouseArea

        anchors.fill: parent

        hoverEnabled: true

        onClicked: parent.clicked()
    }
}
