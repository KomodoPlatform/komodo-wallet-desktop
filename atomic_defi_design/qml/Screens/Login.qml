import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

SetupPage {
    id: login

    // Override
    property var onClickedBack: () => {}
    property var postLoginSuccess: () => {}

    // Local
    function reset() {
        text_error = ""
    }

    function onClickedLogin(password) {
        if(API.app.login(password, selected_wallet_name)) {
            console.log("Success: Login")
            postLoginSuccess()
            return true
        }
        else {
            console.log("Failed: Login")
            text_error = API.app.settings_pg.empty_string + (qsTr("Failed to login"))
            return false
        }
    }

    property string text_error

    image_scale: 0.7
    image_path: General.image_path + "setup-logs.svg"

    content: ColumnLayout {
        spacing: Style.rowSpacing

        function reset() {
            login.reset()
            input_password.reset()
        }

        function trySubmit() {
            if(!submit_button.enabled) return

            if(onClickedLogin(input_password.field.text))
                reset()
        }

        width: 400

        DefaultText {
            text_value: API.app.settings_pg.empty_string + (qsTr("Login") + ": " + selected_wallet_name)
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        PasswordForm {
            id: input_password
            confirm: false
            field.onAccepted: trySubmit()
        }

        RowLayout {
            spacing: Style.buttonSpacing

            DefaultButton {
                text: API.app.settings_pg.empty_string + (qsTr("Back"))
                Layout.fillWidth: true
                onClicked: {
                    reset()
                    onClickedBack()
                }
            }

            PrimaryButton {
                id: submit_button
                Layout.fillWidth: true
                text: API.app.settings_pg.empty_string + (qsTr("Login"))
                onClicked: trySubmit()
                enabled: input_password.isValid()
            }
        }

        DefaultText {
            text_value: API.app.settings_pg.empty_string + (text_error)
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

