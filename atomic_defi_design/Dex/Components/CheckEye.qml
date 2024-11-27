import QtQuick 2.15
import QtQuick.Layouts 1.12

import Qaterial 1.0 as Qaterial

import App 1.0
import Dex.Themes 1.0 as Dex

Item
{
    id: control

    property alias  text: _label.text
    property alias  iconSource: _icon.source
    property var    target

    width: parent.width
    height: row.height

    RowLayout
    {
        id: row
        width: parent.width - 20
        spacing: 10

        Qaterial.ColorIcon
        {
            id: _icon
            Layout.alignment: Qt.AlignVCenter
            source: target.visible ? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
            color: target.visible ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.buttonTextDisabledColor
            iconSize: 17
        }

        DexLabel
        {
            id: _label
            font.pixelSize: 15
            text: ""
            color: target.visible ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.buttonTextDisabledColor
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    DefaultMouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            if (target.visible) target.visible = false
            else target.visible = true
        }
    }
}
