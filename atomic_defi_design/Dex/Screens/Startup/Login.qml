import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

SetupPage
{
    id: login

    property string text_error
    property string walletName

    property bool   _isPasswordWrong: false

    signal backClicked()
    signal loginSucceeded()

    function reset()
    {
        text_error = ""
    }

    function onClickedLogin(password)
    {
        if (API.app.wallet_mgr.login(password, walletName))
        {
            console.info("Success: Login");
            app.currentWalletName = walletName;
            loginSucceeded();
            return true;
        }
        else
        {
            console.info("Failed: Login");
            _isPasswordWrong = true;
            return false;
        }
    }


    image_scale: 1
    backgroundColor: 'transparent'
    image_path: Dex.CurrentTheme.bigLogoPath

    content: ColumnLayout
    {
        id: content

        spacing: 10

        DexLabel
        {
            Layout.alignment: Qt.AlignHCenter
            text: "%1 wallet".arg(walletName)
            color: Dex.CurrentTheme.foregroundColor
            font: DexTypo.body1
            topPadding: 10
        }

        Item
        {
            height: 20
            width: 1
        }

        DexAppPasswordField
        {
            id: _inputPassword
            Layout.alignment: Qt.AlignHCenter
            height: 50
            width: 300
            background.color: Dex.CurrentTheme.floatingBackgroundColor
            field.onAccepted:
            {
                if (_keyChecker.isValid())
                {
                    onClickedLogin(field.text)
                }
                else
                {
                    _inputPassword.error = true
                    _keyChecker.visible = true
                }
            }

            leftIconColor: Dex.CurrentTheme.foregroundColor
            hideFieldButton.icon.color: Dex.CurrentTheme.foregroundColor
        }

        DexKeyChecker
        {
            id: _passwordChecker
            visible: false
            field: _inputPassword.field
        }

        DefaultText
        {
            Layout.alignment: Qt.AlignHCenter
            visible: _isPasswordWrong
            text: qsTr("Incorrect Password")
            color: Dex.CurrentTheme.noColor
        }

        Item
        {
            height: 1
            width: 1
        }

        GradientButton
        {
            Layout.alignment: Qt.AlignHCenter
            radius: width
            width: 300
            text: qsTr("Connect")
            enabled: _passwordChecker.isValid()
            onClicked: _inputPassword.field.accepted()
        }

        DexKeyChecker
        {
            Layout.alignment: Qt.AlignHCenter
            id: _keyChecker
            field: _inputPassword.field
            visible: false
        }

        DexAppButton
        {
            text: qsTr("Cancel")
            color: containsMouse ? Dex.CurrentTheme.buttonColorHovered : 'transparent'
            height: 25
            radius: 20
            width: 100
            border.color: 'transparent'
            Layout.alignment: Qt.AlignHCenter
            font: Qt.font(
            {
                pixelSize: 14,
                letterSpacing: 0.15,
                family: DexTypo.fontFamily,
                weight: Font.Normal
            })
            onClicked: backClicked()
        }
    }
}
