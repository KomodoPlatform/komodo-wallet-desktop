//! Qt Imports.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15

//! Project Imports.
import App 1.0
import Dex.Themes 1.0 as Dex

CheckBox
{
    id: control

    property color textColor: Dex.CurrentTheme.foregroundColor

    property alias boxWidth: _indicator.implicitWidth
    property alias boxHeight: _indicator.implicitHeight

    Universal.accent: Dex.CurrentTheme.accentColor
    Universal.foreground: Dex.CurrentTheme.foregroundColor
    Universal.background: Dex.CurrentTheme.backgroundColor

    font.family: Style.font_family

    contentItem: DefaultText
    {
        text: control.text
        font: control.font
        color: control.textColor
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
            GradientStop { position: 0.1; color: Dex.CurrentTheme.checkBoxGradientStartColor }
            GradientStop { position: 0.6; color: Dex.CurrentTheme.checkBoxGradientEndColor }
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
