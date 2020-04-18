import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
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
        if(API.get().create(password, seed, wallet_name)) {
            console.log("Success: Recover seed")
            postConfirmSuccess()
            return true
        }
        else {
            console.log("Failed: Recover seed")
            text_error = API.get().empty_string + (qsTr("Failed to recover the seed"))
            return false
        }
    }

    property string text_error

    image_scale: 0.7
    image_path: General.image_path + "setup-wallet-restore-2.svg"
    title: API.get().empty_string + (qsTr("Recovery"))
    content: ColumnLayout {
        width: 400

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

            eula.open()
        }

        EulaModal {
            id: eula
            onConfirm: () => {
               if(onClickedConfirm(input_password.field.text, input_seed.field.text, input_wallet_name.field.text))
                   reset()
            }
        }

        WalletNameField {
            id: input_wallet_name
            field.onAccepted: trySubmit()
        }

        TextFieldWithTitle {
            id: input_seed_hidden
            visible: !input_seed.visible
            title: API.get().empty_string + (qsTr("Seed"))
            field.placeholderText: API.get().empty_string + (qsTr("Enter the seed"))
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
            title: API.get().empty_string + (qsTr("Seed"))
            field.placeholderText: API.get().empty_string + (qsTr("Enter the seed"))
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

        CheckBox {
            id: allow_custom_seed
            text: API.get().empty_string + (qsTr("Allow custom seed"))
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
                text: API.get().empty_string + (qsTr("Confirm"))
                onClicked: trySubmit()
                enabled:     // Fields are not empty
                             input_wallet_name.field.acceptableInput === true &&
                             input_seed.field.text !== '' &&
                             input_password.isValid() &&
                             (allow_custom_seed.checked || API.get().mnemonic_validate(input_seed.field.text))
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

