import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property bool copyable: false
    property var onReturn // function


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

        CopyFieldButton {

        }
    }
}


