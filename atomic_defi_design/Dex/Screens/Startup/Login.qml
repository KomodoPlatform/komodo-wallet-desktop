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

    signal backClicked()
    signal loginSucceeded()

    function reset() { text_error = "" }

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
            text_error = qsTr("Incorrect Password");
            return false;
        }
    }


    image_scale: 0.7
    backgroundColor: 'transparent'
    image_path: Dex.CurrentTheme.bigLogoPath

    content: ColumnLayout
    {
        id: content

        spacing: 20

        DexLabel
        {
            Layout.alignment: Qt.AlignHCenter
            text: "%1 wallet".arg(walletName)
            color: Dex.CurrentTheme.foregroundColor
            font: DexTypo.body1
            topPadding: 10
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

        DefaultButton
        {
            Layout.alignment: Qt.AlignHCenter
            radius: width
            width: 150
            text: qsTr("connect")
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

        Qaterial.AppBarButton
        {
            Layout.alignment: Qt.AlignHCenter
            width: 80
            icon.width: 40
            icon.height: 40
            icon.source: Qaterial.Icons.close
            icon.color: Dex.CurrentTheme.foregroundColor
            backgroundColor: 'transparent'
            onClicked: backClicked()
        }
    }
}
