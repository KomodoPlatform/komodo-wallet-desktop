import QtQuick 2.15
import QtQuick.Layouts 1.15

BasicModal {
    id: root

    property alias header: modal_content.title
    property alias field: text_area.field

    ModalContent {
        id: modal_content

        TextAreaWithTitle {
            id: text_area
            Layout.fillWidth: true
            field.readOnly: true
            copyable: true
            remove_newline: false
            title: ""
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
        ]
    }
}
