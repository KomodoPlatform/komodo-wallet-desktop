import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property alias hide_button: hide_button
    property alias hide_button_area: hide_button.mouse_area
    property bool copyable: false
    property bool hidable: false
    property var onReturn // function

    property alias remove_newline: input_field.remove_newline
    property bool hiding: true



    // Local
    function reset() {
        input_field.text = ''
    }

    RowLayout {
        DefaultText {
            id: title_text
        }
    }

    DefaultTextArea {
        id: input_field
        Layout.fillWidth: true

        HideFieldButton {
            id: hide_button
        }

        CopyFieldButton {

        }
    }
}


