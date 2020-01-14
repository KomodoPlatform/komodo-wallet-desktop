import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    // Override
    function onClickedBack() {}
    function postCreateSuccess() {}

    // Local
    function onClickedCreate(password, generated_seed, confirm_seed) {
        if(MockAPI.getAtomicApp().create(password, generated_seed)) {
            console.log("Success: Create wallet")
            postCreateSuccess()
        }
        else {
            console.log("Failed: Create wallet")
        }
    }

    image_scale: 0.7
    image_path: General.image_path + "setup-welcome-wallet.svg"
    title: "New User"

    content: ColumnLayout {
        width: 400

        TextAreaWithTitle {
            id: input_generated_seed
            title: qsTr("Generated Seed")
            field.text: MockAPI.getAtomicApp().get_mnemonic()
            field.readOnly: true
            copyable: true
        }

        TextAreaWithTitle {
            id: input_confirm_seed
            title: qsTr("Confirm Seed")
            field.placeholderText: qsTr("Enter the generated seed here")
        }

        PasswordField {
            id: input_password
        }

        RowLayout {
            Button {
                text: qsTr("Back")
                onClicked: onClickedBack()
            }

            Button {
                text: qsTr("Create")
                onClicked: onClickedCreate(input_password.field.text, input_generated_seed.field.text, input_confirm_seed.field.text)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
