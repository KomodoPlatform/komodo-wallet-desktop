import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    // Override
    function onClickedBack() {}
    function postConfirmSuccess() {}

    // Local
    function onClickedConfirm(password, seed) {
        if(MockAPI.getAtomicApp().create(password, seed)) {
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
    title: "Recovery"
    content: ColumnLayout {
        width: 400

        TextAreaWithTitle {
            id: input_seed
            title: qsTr("Seed")
            field.placeholderText: qsTr("Enter the seed")
        }

        PasswordField {
            id: input_password
        }

        PasswordField {
            id: input_confirm_password
            title: qsTr("Confirm Password")
            field.placeholderText: qsTr("Enter the same password to confirm")
        }

        RowLayout {
            Button {
                text: qsTr("Back")
                onClicked: onClickedBack()
            }

            Button {
                text: qsTr("Confirm")
                onClicked: onClickedConfirm(input_password.field.text, input_seed.field.text)
                enabled:     // Fields are not empty
                             input_seed.field.text.length !== '' &&
                             input_password.field.acceptableInput === true &&
                             input_confirm_password.field.acceptableInput === true &&
                             // Correct confirm fields
                             input_password.field.text === input_confirm_password.field.text
            }
        }

        DefaultText {
            text: text_error
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

