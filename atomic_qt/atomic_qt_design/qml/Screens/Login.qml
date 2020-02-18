import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    id: login
    // Override
    function onClickedBack() {}
    function postLoginSuccess() {}

    // Local
    function reset() {
        text_error = ""
    }

    function onClickedLogin(password) {
        if(API.get().login(password, API.get().wallet_default_name)) {
            console.log("Success: Login")
            postLoginSuccess()
            return true
        }
        else {
            console.log("Failed: Login")
            text_error = "Failed to login"
            return false
        }
    }

    property string text_error

    image_scale: 0.7
    image_path: General.image_path + "setup-logs.svg"
    title: qsTr("Login") + ": " + API.get().wallet_default_name
    content: ColumnLayout {
        function reset() {
            login.reset()
            input_password.field.text = ""
        }

        width: 275
        PasswordField {
            id: input_password
        }

        RowLayout {
            Button {
                text: qsTr("Back")
                onClicked: {
                    API.get().wallet_default_name = ""
                    reset()
                    onClickedBack()
                }
            }

            Button {
                text: qsTr("Login")
                onClicked: {
                    if(onClickedLogin(input_password.field.text))
                        reset()
                }
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

