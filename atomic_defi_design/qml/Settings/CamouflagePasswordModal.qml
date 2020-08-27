import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    width: 1100

    onClosed: {
        input_password.reset()
    }

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().settings_pg.empty_string + (qsTr("Setup Camouflage Password"))
        }

        FloatingBackground {
            id: warning_bg
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            width: parent.width - 5
            height: warning_texts.height + 20

            Column {
                id: warning_texts
                anchors.centerIn: parent
                width: parent.width
                spacing: 10

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: API.get().settings_pg.empty_string + (qsTr("Camouflage password is a secret wallet password which can be used in emergency situations."))
                    font.pixelSize: Style.textSize2
                }

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: API.get().settings_pg.empty_string + (qsTr("On login with it balance lower than actual will be displayed."))
                }

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: API.get().settings_pg.empty_string + (qsTr("It forming as <your encryption password> + <appendix>."))
                }
            }
        }

        PasswordForm {
            id: input_password
            Layout.fillWidth: true
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter a suffix"))
            high_security: false
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Save"))
                Layout.fillWidth: true
                enabled: input_password.isValid()
                onClicked: {
                    API.get().set_emergency_password(input_password.field.text)
                    root.close()
                }
            }
        }
    }
}
