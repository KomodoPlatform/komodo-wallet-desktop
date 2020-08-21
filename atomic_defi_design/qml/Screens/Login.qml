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

    // Enable protection mode
    property bool protection_mode: false
    Keys.onPressed: {
        if(app.current_page !== idx_login) return

        if(event.key === Qt.Key_P &&
                (event.modifiers & Qt.ShiftModifier) &&
                // For OSX CTRL is Meta
                ((event.modifiers & Qt.ControlModifier) || (event.modifiers & Qt.MetaModifier))
        ) {
                protection_mode = true
                event.accepted = true
        }
    }

    // Local
    function reset() {
        text_error = ""
    }

    function onClickedLogin(password) {
        if(API.get().login(password, selected_wallet_name, protection_mode)) {
            console.log("Success: Login")
            protection_mode = false
            postLoginSuccess()
            return true
        }
        else {
            console.log("Failed: Login")
            text_error = API.get().settings_pg.empty_string + (qsTr("Failed to login"))
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
            text_value: API.get().settings_pg.empty_string + (qsTr("Login") + ": " + selected_wallet_name)
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
                text: API.get().settings_pg.empty_string + (qsTr("Back"))
                Layout.fillWidth: true
                onClicked: {
                    reset()
                    onClickedBack()
                }
            }

            PrimaryButton {
                id: submit_button
                Layout.fillWidth: true
                text: API.get().settings_pg.empty_string + (qsTr("Login"))
                onClicked: trySubmit()
                enabled: input_password.isValid()
            }
        }

        DefaultText {
            text_value: API.get().settings_pg.empty_string + (text_error)
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

