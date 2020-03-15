import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    // Override
    function onClickedBack() {}
    function postConfirmSuccess() {}

    // Local
    function onClickedConfirm(password, seed, wallet_name) {
        if(API.get().create(password, seed, wallet_name)) {
            console.log("Success: Recover seed")
            postConfirmSuccess()
        }
        else {
            console.log("Failed: Recover seed")
            text_error = "Failed to recover the seed"
        }
    }

    property string text_error

    image_scale: 0.7
    image_path: General.image_path + "setup-wallet-restore-2.svg"
    title: API.get().empty_string + (qsTr("Recovery"))
    content: ColumnLayout {
        width: 400

        WalletNameField {
            id: input_wallet_name
        }

        TextAreaWithTitle {
            id: input_seed
            title: API.get().empty_string + (qsTr("Seed"))
            field.placeholderText: API.get().empty_string + (qsTr("Enter the seed"))
        }

        PasswordForm {
            id: input_password
        }

        RowLayout {
            DefaultButton {
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("Back"))
                onClicked: onClickedBack()
            }

            PrimaryButton {
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("Confirm"))
                onClicked: onClickedConfirm(input_password.field.text, input_seed.field.text, input_wallet_name.field.text)
                enabled:     // Fields are not empty
                             input_wallet_name.field.acceptableInput === true &&
                             input_seed.field.text !== '' &&
                             input_password.isValid()
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

