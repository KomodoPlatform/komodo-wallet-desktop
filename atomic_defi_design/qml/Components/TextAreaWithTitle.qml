import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property alias save_button: save_button
    property alias hide_button: hide_button
    property alias hide_button_area: hide_button.mouse_area
    property bool copyable: false
    property bool hidable: false
    property var onReturn // function

    property alias remove_newline: input_field.remove_newline
    property bool hiding: true

    property bool saveable: false

    signal saved()

    // Local
    function reset() {
        input_field.text = ''
    }

    RowLayout {
        TitleText {
            id: title_text
            Layout.alignment: Qt.AlignVCenter
        }

        DefaultButton {
            id: save_button
            button_type: input_field.enabled ? "danger" : "primary"
            Layout.alignment: Qt.AlignVCenter
            text: input_field.enabled ? qsTr("Save") : qsTr("Edit")
            visible: saveable
            onClicked: {
                if(input_field.enabled) saved()
                input_field.enabled = !input_field.enabled
            }
            font.pixelSize: Style.textSizeSmall
            minWidth: 0
            implicitHeight: text_obj.height * 1.25
        }
    }

    DefaultTextArea {
        id: input_field
        enabled: !saveable
        Layout.fillWidth: true

        HideFieldButton {
            id: hide_button
        }

        CopyFieldButton {

        }
    }
}


