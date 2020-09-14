import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

BasicModal {
    id: root

    property alias header: text_area.title
    property alias field: text_area.field

    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Log"))

        TextAreaWithTitle {
            id: text_area
            Layout.fillWidth: true
            field.readOnly: true
            copyable: true
            remove_newline: false
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }
        ]
    }
}
