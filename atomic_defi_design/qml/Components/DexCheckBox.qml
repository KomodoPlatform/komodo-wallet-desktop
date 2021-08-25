//! Qt Imports.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15

//! Project Imports.
import App 1.0

CheckBox
{
    id: control

    property alias boxWidth: _indicator.implicitWidth
    property alias boxHeight: _indicator.implicitHeight

    Universal.accent: DexTheme.accentColor
    Universal.foreground: DexTheme.foregroundColor
    Universal.background: DexTheme.backgroundColor

    font.family: Style.font_family

    contentItem: DexLabel
    {
        text: control.text
        font: control.font
        color: DexTheme.foregroundColor
        horizontalAlignment: DexLabel.AlignLeft
        verticalAlignment: DexLabel.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
        wrapMode: Label.Wrap
    }

    indicator: DexRectangle
    {
        id: _indicator

        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding - control.spacing
        anchors.verticalCenter: control.verticalCenter
        radius: 20

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
            implicitWidth: parent.width - 6
            implicitHeight: parent.height - 6
            radius: parent.radius
        }

        opacity: enabled ? 1 : 0.5
    }

    DefaultMouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
