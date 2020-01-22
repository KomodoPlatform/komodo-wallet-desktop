import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    // Override
    function onClickedRecoverSeed() {}
    function postLoginSuccess() {}

    // Local
    function onClickedLogin(password) {
        if(MockAPI.app().login(password)) {
            console.log("Success: Login")
            postLoginSuccess()
        }
        else {
            console.log("Failed: Login")
            text_error = "Failed to login"
        }
    }

    property string text_error

    image_scale: 0.7
    image_path: General.image_path + "setup-logs.svg"
    title: "Login"
    content: ColumnLayout {
        width: 275
        PasswordField {
            id: input_password
        }

        RowLayout {
            Button {
                text: qsTr("Recover Seed")
                onClicked: onClickedRecoverSeed()
            }

            Button {
                text: qsTr("Login")
                onClicked: onClickedLogin(input_password.field.text)
                enabled:    // Fields are not empty
                            input_password.field.acceptableInput === true
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

