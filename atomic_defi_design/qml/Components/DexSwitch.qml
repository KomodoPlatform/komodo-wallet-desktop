//! Qt Imports.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15

//! Projects Imports.
import "../Constants"
import App 1.0

Switch
{
    id: control

    property alias switchButtonWidth: indicator.width
    property alias switchButtonHeight: indicator.height
    property alias switchButtonRadius: indicator.radius

    Universal.accent: DexTheme.accent
    Universal.foreground: DexTheme.foregroundColor
    Universal.background: DexTheme.backgroundColor

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
            GradientStop { position: 0.0; color: DexTheme.buttonGradientEnabled1 }
            GradientStop { position: 0.7; color: DexTheme.buttonGradientEnabled2 }
        }

        DexRectangle
        {
            visible: !control.checked
            anchors.centerIn: parent
            width: parent.width - 6
            height: parent.height - 6
            radius: parent.radius
            color: DexTheme.backgroundColor
        }

        DexRectangle
        {
            x: control.checked ? parent.width - width - 4 : 4
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width / 2 - 2
            height: parent.height - 6
            radius: parent.radius + 2

            gradient: Gradient
            {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: control.checked ? DexTheme.backgroundColor : DexTheme.buttonGradientEnabled1 }
                GradientStop { position: 0.7; color: control.checked ? DexTheme.backgroundColor : DexTheme.buttonGradientEnabled2 }
            }
        }
    }

    DefaultMouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
