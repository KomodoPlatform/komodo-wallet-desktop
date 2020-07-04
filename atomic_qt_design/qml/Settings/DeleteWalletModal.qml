import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

    property bool wrong_password: false

    width: 800

    onClosed: {
        wrong_password = false
        input_password.reset()
    }

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("Delete Wallet"))
        }

        FloatingBackground {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            color: Style.colorRed2

            width: parent.width - 5
            height: warning_texts.height + 20

            ColumnLayout {
                id: warning_texts
                anchors.centerIn: parent

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text_value: API.get().empty_string + (qsTr("Are you sure you want to delete %1 wallet?", "WALLET_NAME").arg(API.get().wallet_default_name))
                    font.pixelSize: Style.textSize2
                }

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text_value: API.get().empty_string + (qsTr("If so, make sure you record your seed phrase in order to restore your wallet in future."))
                }
            }
        }

        PasswordForm {
            id: input_password
            Layout.fillWidth: true
            confirm: false
            field.placeholderText: API.get().empty_string + (qsTr("Enter the password of your wallet"))
        }

        DefaultText {
            text_value: API.get().empty_string + (qsTr("Wrong Password"))
            color: Style.colorRed
            visible: wrong_password
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            DangerButton {
                text: API.get().empty_string + (qsTr("Delete"))
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
        }
    }
}
