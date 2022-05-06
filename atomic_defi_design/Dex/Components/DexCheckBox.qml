//! Qt Imports.
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15

//! Project Imports.
import App 1.0
import Dex.Themes 1.0 as Dex

CheckBox
{
    id: control

    property alias label: _label
    property alias boxWidth: _indicator.implicitWidth
    property alias boxHeight: _indicator.implicitHeight
    property alias mouseArea: mouse_area
    property color textColor: Dex.CurrentTheme.foregroundColor
    property int labelWidth: 0

    font.family: Style.font_family
    Layout.preferredWidth: childrenRect.width
    Layout.preferredHeight: childrenRect.height

    indicator: DexRectangle
    {
        id: _indicator
        anchors.verticalCenter: control.verticalCenter

        implicitWidth: 26
        implicitHeight: 26
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
            width: parent.width - 6
            height: parent.height - 6
            radius: parent.radius
        }

        opacity: enabled ? 1 : 0.5
    }

    contentItem: RowLayout
    {
        id: _content
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: labelWidth
        height: _label.height
        spacing: 0

        DexLabel
        {
            id: _label
            text: control.text
            font: control.font
            color: control.textColor
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
            wrapMode: Label.Wrap
        }
    }

    DexMouseArea
    {
        id: mouse_area
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
