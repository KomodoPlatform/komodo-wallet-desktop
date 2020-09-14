import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

BasicModal {
    id: root

    property bool wrong_password: false

    width: 1100

    onClosed: {
        wrong_password = false
        input_password.reset()
    }

    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Delete Wallet"))

        FloatingBackground {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            color: Style.colorRed2

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

                    text_value: API.get().settings_pg.empty_string + (qsTr("Are you sure you want to delete %1 wallet?", "WALLET_NAME").arg(API.get().wallet_default_name))
                    font.pixelSize: Style.textSize2
                }

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: API.get().settings_pg.empty_string + (qsTr("If so, make sure you record your seed phrase in order to restore your wallet in future."))
                }
            }
        }

        PasswordForm {
            id: input_password
            Layout.fillWidth: true
            confirm: false
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the password of your wallet"))
        }

        DefaultText {
            text_value: API.get().settings_pg.empty_string + (qsTr("Wrong Password"))
            color: Style.colorRed
            visible: wrong_password
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            },

            DangerButton {
                text: API.get().settings_pg.empty_string + (qsTr("Delete"))
                Layout.fillWidth: true
                enabled: input_password.isValid()
                onClicked: {
                    if(API.get().confirm_password(API.get().wallet_default_name, input_password.field.text)) {
                        root.close()
                        wrong_password = false

                        API.get().delete_wallet(API.get().wallet_default_name)
                        disconnect()
                    }
                    else {
                        wrong_password = true
                    }
                }
            }
        ]
    }
}
