import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

BasicModal {
    id: root

    width: 1100

    onClosed: {
        input_password.reset()
    }

    ModalContent {
        title: qsTr("Setup Camouflage Password")

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

                    text_value: qsTr("Camouflage Password is a secret password for emergency situations.")
                    font.pixelSize: Style.textSize2
                }

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: qsTr("Using it to login will display your balance lower than it actually is.")
                }

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: qsTr("Here you enter the suffix and at login you need to enter {real_password}{suffix}")
                }
            }
        }

        PasswordForm {
            id: input_password
            Layout.fillWidth: true
            field.placeholderText: qsTr("Enter a suffix")
            high_security: false
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: root.close()
            },

            PrimaryButton {
                text: qsTr("Save")
                Layout.fillWidth: true
                enabled: input_password.isValid()
                onClicked: {
                    API.app.wallet_mgr.set_emergency_password(input_password.field.text)
                    root.close()
                }
            }
        ]
    }
}
