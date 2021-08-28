import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import App 1.0

SetupPage {
    id: login

    // Override
    signal clickedBack()
    signal postLoginSuccess()

    // Local
    function reset() {
        text_error = ""
    }

    function onClickedLogin(password) {
        if (API.app.wallet_mgr.login(password, selected_wallet_name)) {
            console.log("Success: Login")
            app.currentWalletName = selected_wallet_name
            postLoginSuccess()
            return true
        } else {
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
            if (!submit_button.enabled) return

            if (onClickedLogin(input_password.field.text))
                reset()
        }

        width: 400

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Qaterial.AppBarButton {
                icon.source: Qaterial.Icons.arrowLeft
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    reset()
                    onClickedBack()
                }
            }

            DexLabel {
                font: DexTypo.head6
                text_value: qsTr("Login")
                Layout.alignment: Qt.AlignVCenter
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 5
        }

        DexAppTextField {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            background.border.width: 1
            background.radius: 25
            enabled: false
            opacity: enabled ? 1 : .5
            background.border.color: field.focus ? DexTheme.accentColor : Style.colorBorder
            field.font: DexTypo.head6
            field.horizontalAlignment: Qt.AlignLeft
            field.leftPadding: 75
            field.text: selected_wallet_name

            DexRectangle {
                x: 5
                height: 40
                width: 60
                radius: 20
                color: DexTheme.accentColor
                anchors.verticalCenter: parent.verticalCenter
                Qaterial.ColorIcon {
                    anchors.centerIn: parent
                    iconSize: 19
                    source: Qaterial.Icons.account
                    color: DexTheme.surfaceColor
                }

            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 5
            opacity: .8

        }

        DexAppTextField {
            id: _inputPassword
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            background.border.width: 1
            background.radius: 25
            background.border.color: field.focus ? DexTheme.accentColor : Style.colorBorder
            field.echoMode: TextField.Password
            field.font: field.echoMode === TextField.Password ? field.text === "" ? DexTypo.body1 : DexTypo.head5 : DexTypo.head6
            field.horizontalAlignment: Qt.AlignLeft
            field.leftPadding: 75
            field.placeholderText: qsTr("Type password")
            field.onAccepted: trySubmit()
            DexRectangle {
                x: 5
                height: 40
                width: 60
                radius: 20
                color: DexTheme.accentColor
                anchors.verticalCenter: parent.verticalCenter
                Qaterial.ColorIcon {
                    anchors.centerIn: parent
                    iconSize: 19
                    source: Qaterial.Icons.keyVariant
                    color: DexTheme.surfaceColor
                }

            }
            Qaterial.AppBarButton {
                opacity: .8
                icon {
                    source: _inputPassword.field.echoMode === TextField.Password ? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
                    color: DexTheme.accentColor
                }
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10
                }
                onClicked: {
                    if (_inputPassword.field.echoMode === TextField.Password) {
                        _inputPassword.field.echoMode = TextField.Normal
                    } else {
                        _inputPassword.field.echoMode = TextField.Password
                    }
                }
            }
        }
        PasswordForm {
            id: input_password
            confirm: false
            visible: false
            field.text: _inputPassword.field.text
            field.onAccepted: trySubmit()
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
        }

        RowLayout {
            Layout.preferredWidth: 400
            spacing: Style.buttonSpacing

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
            }

            DexButton {
                id: _back
                text: qsTr("Back")
                visible: false

            }

            DexAppButton {
                id: submit_button
                text: qsTr("Login")
                enabled: input_password.isValid()
                onClicked: trySubmit()
                radius: 20
                backgroundColor: DexTheme.accentColor
                Layout.preferredWidth: _nextRow.implicitWidth + 40
                Layout.preferredHeight: 45
                label.color: 'transparent'
                Row {
                    id: _nextRow
                    anchors.centerIn: parent
                    spacing: 10
                    opacity: submit_button.enabled ? 1 : .6
                    DexLabel {
                        text: qsTr("Connect")
                        font: DexTypo.button
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Qaterial.ColorIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        source: Qaterial.Icons.arrowRight
                        iconSize: 14
                    }
                }
            }
        }

        DefaultText {
            text_value: text_error
            color: Style.colorRed
            visible: text !== ''
        }
    }
}