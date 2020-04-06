import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    id: new_user

    // Override
    property var onClickedBack: () => {}
    property var postCreateSuccess: () => {}

    property string current_mnemonic
    property string text_error

    function onOpened() {
        current_mnemonic = API.get().get_mnemonic()
    }

    // Local
    function reset() {
        current_mnemonic = ""
        text_error = ""
    }

    function onClickedCreate(password, generated_seed, confirm_seed, wallet_name) {
        if(API.get().create(password, generated_seed, wallet_name)) {
            console.log("Success: Create wallet")
            postCreateSuccess()
            return true
        }
        else {
            console.log("Failed: Create wallet")
            text_error = "Failed to create a wallet"
            return false
        }
    }

    image_scale: 0.7
    image_path: General.image_path + "setup-welcome-wallet.svg"
    title: API.get().empty_string + (qsTr("New User"))

    content: ColumnLayout {
        width: 600

        function reset() {
            new_user.reset()
            input_wallet_name.reset()
            input_confirm_seed.reset()
            input_password.reset()
        }

        function trySubmit() {
            if(!submit_button.enabled) return

            if(onClickedCreate(input_password.field.text, input_generated_seed.field.text, input_confirm_seed.field.text, input_wallet_name.field.text))
                reset()
        }

        WalletNameField {
            id: input_wallet_name
            field.onAccepted: trySubmit()
        }


        Rectangle {
            Layout.topMargin: 10
            Layout.bottomMargin: Layout.topMargin
            Layout.fillWidth: true
            color: Style.colorRed3
            radius: 10
            height: warning_texts.height + 20

            ColumnLayout {
                id: warning_texts

                anchors.centerIn: parent

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter
                    text: API.get().empty_string + (qsTr("Important: Back up your seed phrase before proceeding!"))
                }

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter
                    text: API.get().empty_string + (qsTr("We recommend storing it offline."))
                    font.pixelSize: Style.textSizeSmall4
                    color: Style.colorWhite4
                }
            }
        }

        TextAreaWithTitle {
            id: input_generated_seed
            title: API.get().empty_string + (qsTr("Generated Seed"))
            field.text: current_mnemonic
            field.readOnly: true
            copyable: true
            onReturn: trySubmit
        }

        TextAreaWithTitle {
            id: input_confirm_seed
            title: API.get().empty_string + (qsTr("Confirm Seed"))
            field.placeholderText: API.get().empty_string + (qsTr("Enter the generated seed here"))
            onReturn: trySubmit
        }

        PasswordForm {
            id: input_password

            field.onAccepted: trySubmit()
            confirm_field.onAccepted: trySubmit()
        }

        RowLayout {
            DefaultButton {
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("Back"))
                onClicked: {
                    reset()
                    onClickedBack()
                }
            }

            PrimaryButton {
                id: submit_button
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("Create"))
                onClicked: trySubmit()
                enabled:    // Fields are not empty
                            input_wallet_name.field.acceptableInput === true &&
                            input_password.isValid() &&
                            // Correct confirm fields
                            input_generated_seed.field.text === input_confirm_seed.field.text
            }
        }

        DefaultText {
            text: API.get().empty_string + (text_error)
            color: Style.colorRed
            visible: text !== ''
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
