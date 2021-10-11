//! Qt Imports.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15

//! Projects Imports.
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

Switch
{
    id: control

    property alias switchButtonWidth: indicator.width
    property alias switchButtonHeight: indicator.height
    property alias switchButtonRadius: indicator.radius
    property alias mouseArea: _mouseArea

    Universal.foreground: Dex.CurrentTheme.foregroundColor
    Universal.background: Dex.CurrentTheme.backgroundColor

    font.family: DexTypo.fontFamily
    indicator: DexRectangle
    {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        width: 52
        height: 28
        radius: 13

        gradient: Gradient
        {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.2; color: Dex.CurrentTheme.switchGradientStartColor }
            GradientStop { position: 0.8; color: Dex.CurrentTheme.switchGradientEndColor }
        }

        DexRectangle
        {
            visible: !control.checked
            anchors.centerIn: parent
            width: parent.width - 6
            height: parent.height - 6
            radius: parent.radius
            color: Dex.CurrentTheme.backgroundColor
        }

        Rectangle
        {
            x: control.checked ? parent.width - width - 4 : 4
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width / 2 - 2
            height: parent.height - 6
            radius: parent.radius + 2
            color: Dex.CurrentTheme.foregroundColor
        }
    }

    DefaultMouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
