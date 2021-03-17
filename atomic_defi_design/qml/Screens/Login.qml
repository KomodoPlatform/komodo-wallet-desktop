import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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
        if(API.app.wallet_mgr.login(password, selected_wallet_name)) {
            console.log("Success: Login")
            postLoginSuccess()
            return true
        }
        else {
            console.log("Failed: Login")
            text_error = qsTr("Incorrect Password")
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
            text_value: qsTr("Wallet Name") + ": " + selected_wallet_name
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
                id: _back
                text: qsTr("Back")
                Layout.fillWidth: true
                onClicked: {
                    reset()
                    onClickedBack()
                }
            }

            PrimaryButton {
                id: submit_button
                Layout.fillWidth: true
                implicitHeight: _back.implicitHeight
                text: qsTr("Login")
                onClicked: trySubmit()
                enabled: input_password.isValid()
            }
        }

        DefaultText {
            text_value: text_error
            color: Style.colorRed
            visible: text !== ''
        }
    }
}
