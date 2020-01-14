import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property bool copyable: false

    RowLayout {
        DefaultText {
            id: title_text
        }

        Button {
            visible: copyable
            text: qsTr("Copy")
            onClicked: () => {
                input_field.selectAll()
                input_field.copy()
            }
        }
    }

    TextArea {
        id: input_field
        Layout.fillWidth: true
        selectByMouse: true
        wrapMode: TextEdit.WordWrap
    }
}


