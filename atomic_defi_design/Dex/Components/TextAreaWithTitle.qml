import QtQuick 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

ColumnLayout
{
    id: control
    property alias title: title_text.text
    property color titleColor: Dex.CurrentTheme.foregroundColor
    property alias field: input_field
    property alias save_button: save_button
    property alias hide_button: hide_button
    property alias hide_button_area: hide_button.mouseArea
    property bool  copyable: false
    property bool  hidable: false
    property var   onReturn // function

    property alias remove_newline: input_field.remove_newline
    property bool  hiding: true

    property bool  saveable: false

    signal saved()
    signal copied()

    function reset() { input_field.text = '' }

    TitleText
    {
        id: title_text

        Layout.alignment: Qt.AlignVCenter

        color: titleColor

        Qaterial.Icon
        {
            visible: control.copyable

            Layout.alignment: Qt.AlignVCenter

            x: title_text.implicitWidth + 10
            size: 16
            icon: Qaterial.Icons.contentCopy
            color: copyArea.containsMouse ? Dex.CurrentTheme.accentColor : Dex.CurrentTheme.foregroundColor

            DexMouseArea
            {
                id: copyArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked:
                {
                    Qaterial.Clipboard.text = input_field.text
                    control.copied()
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: input_field.height + 5
        DexTextArea {
            id: input_field
            enabled: !saveable
            width: parent.width - 6
            rightPadding: 10
            anchors.centerIn: parent
            background: DexRectangle {
                color: Dex.CurrentTheme.accentColor
                opacity: .7
                radius: 8
                border.color: input_field.focus ? Dex.CurrentTheme.accentColor : Dex.CurrentTheme.backgroundColor
                border.width: input_field.focus ? 2 : 0
            }
            HideFieldButton {
                id: hide_button
            }
        }

        DexAppButton {
            anchors.verticalCenter: parent.verticalCenter
            id: save_button
            anchors.right: parent.right
            anchors.rightMargin: 8
            text: input_field.enabled ? qsTr("Save") : qsTr("Edit")
            visible: saveable
            onClicked: {
                if(input_field.enabled) saved()
                input_field.enabled = !input_field.enabled
            }
            font.pixelSize: Style.textSizeSmall
            height: 20
        }
    } 
}
