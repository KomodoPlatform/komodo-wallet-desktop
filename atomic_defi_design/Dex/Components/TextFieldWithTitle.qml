import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex


ColumnLayout
{
    id: control
    Layout.fillWidth: true
    Layout.fillHeight: true

    property bool copyable: false
    property bool hidable: false
    property bool required: false
    property bool hiding: true

    property alias title: title_text.text
    property alias field: input_field
    property alias max_length: input_field.maximumLength

    property alias hide_button: hide_button
    property alias hide_button_area: hide_button.mouseArea

    // Local
    function reset()
    {
        input_field.text = ''
        hiding = true
    }

    spacing: Style.rowSpacingSmall

    RowLayout
    {
        visible: control.title !== ""
        TitleText
        {
            id: title_text
            visible: text !== ''
        }

        DexLabel
        {
            visible: required && input_field.text === ''
            font.pixelSize: Style.textSizeSmall2
            text_value: qsTr("Required")
            color: Style.colorRed
        }
    }

    DexTextField
    {
        id: input_field

        echoMode: hidable && hiding ? TextInput.Password : TextInput.Normal

        Layout.fillWidth: true
        Layout.fillHeight: true

        HideFieldButton { id: hide_button }

        CopyFieldButton { }
    }
}
