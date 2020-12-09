import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"

SetupPage {
    id: recover_seed
    // Override
    property var onClickedBack: () => {}
    property var postConfirmSuccess: () => {}

    // Local
    function reset() {
        text_error = ""
    }

    function onClickedConfirm(password, seed, wallet_name) {
        if(API.app.wallet_mgr.create(password, seed, wallet_name)) {
            console.log("Success: Recover seed")
            selected_wallet_name = wallet_name
            postConfirmSuccess()
            return true
        }
        else {
            console.log("Failed: Recover seed")
            text_error = qsTr("Failed to recover the seed")
            return false
        }
    }

    property string text_error

    image_scale: 0.7

    // Removed the image for now, no space
    // image_path: General.image_path + "setup-wallet-restore-2.svg"

    content: ColumnLayout {
        width: 400
        spacing: Style.rowSpacing

        DefaultText {
            text_value: qsTr("Recover Wallet")
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        function reset() {
            recover_seed.reset()
            input_wallet_name.reset()
            input_seed.reset()
            input_seed_hidden.reset()
            input_password.reset()
            input_seed.visible = false
        }

        function trySubmit() {
            if(!submit_button.enabled) return

            text_error = General.checkIfWalletExists(input_wallet_name.field.text)
            if(text_error !== "") return

            eula_modal.open()
        }


        ModalLoader {
            id: eula_modal
            sourceComponent: EulaModal {
                onConfirm: () => {
                   if(onClickedConfirm(input_password.field.text, input_seed.field.text, input_wallet_name.field.text))
                       reset()
                }
            }
        }

        WalletNameField {
            id: input_wallet_name
            field.onAccepted: trySubmit()
        }

        TextFieldWithTitle {
            id: input_seed_hidden
            visible: !input_seed.visible
            title: qsTr("Seed")
            field.placeholderText: qsTr("Enter the seed")
            field.onTextChanged: {
                input_seed.field.text = field.text
            }
            hidable: true
            hiding: true
            hide_button.use_default_behaviour: false
            hide_button_area.onClicked: {
                input_seed.visible = true
                // input_seed.field.focus = true // This puts the cursor to left, not good
            }

            field.onAccepted: trySubmit()
        }

        TextAreaWithTitle {
            id: input_seed
            visible: false
            title: qsTr("Seed")
            field.placeholderText: qsTr("Enter the seed")
            field.onTextChanged: {
                input_seed_hidden.field.text = field.text
            }

            hidable: true
            hiding: false
            hide_button.use_default_behaviour: false
            hide_button_area.onClicked: {
                visible = false
                // input_seed_hidden.field.focus = true // This puts the cursor to left, not good
            }
            onReturn: trySubmit
        }

        DefaultCheckBox {
            id: allow_custom_seed
            text: qsTr("Allow custom seed")
        }

        PasswordForm {
            id: input_password

            field.onAccepted: trySubmit()
            confirm_field.onAccepted: trySubmit()
        }

        RowLayout {
            spacing: Style.buttonSpacing

            DefaultButton {
                Layout.fillWidth: true
                text: qsTr("Back")
                onClicked: {
                    reset()
                    onClickedBack()
                }
            }

            PrimaryButton {
                id: submit_button
                Layout.fillWidth: true
                text: qsTr("Confirm")
                onClicked: trySubmit()
                enabled:     // Fields are not empty
                             input_wallet_name.field.acceptableInput === true &&
                             input_seed.field.text !== '' &&
                             input_password.isValid() &&
                             (allow_custom_seed.checked || API.app.wallet_mgr.mnemonic_validate(input_seed.field.text))
            }
        }

        DefaultText {
            text_value: text_error
            color: Style.colorRed
            visible: text !== ''
        }
    }
}
