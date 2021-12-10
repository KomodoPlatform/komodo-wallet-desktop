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
    id: recover_seed

    property int currentStep: 0
    property string text_error

    signal backClicked()
    signal postConfirmSuccess(string walletName)

    function reset()
    {
        text_error = "";
    }

    function onClickedConfirm(password, seed, wallet_name)
    {
        if (API.app.wallet_mgr.create(password, seed, wallet_name))
        {
            postConfirmSuccess(wallet_name);
            return true;
        }
        else
        {
            text_error = qsTr("Failed to Import the wallet");
            return false;
        }
    }

    image_scale: 0.7

    content: DexRectangle
    {
        color: Dex.CurrentTheme.floatingBackgroundColor
        width: column_layout.width + 50
        height: column_layout.height + 60
        radius: 18
        function reset()
        {
            recover_seed.reset();
            input_wallet_name.reset();
            _seedField.field.text = "";
            _inputPassword.field.text = "";
        }

        function trySubmit()
        {
            if (!submit_button.enabled) return;

            text_error = General.checkIfWalletExists(input_wallet_name.field.text);
            if (text_error !== "") return;

            eula_modal.open();
        }

        function tryPassLevel1()
        {
            if (input_wallet_name.field.text == "") input_wallet_name.error = true;

            if (_seedField.isValid() && input_wallet_name.field.text !== "")
            {
                let checkWalletName = General.checkIfWalletExists(input_wallet_name.field.text)
                if (checkWalletName === "")
                {
                    _seedField.error = false;
                    _inputPassword.field.text = "";
                    _inputPasswordConfirm.field.text = "";
                    currentStep++;
                }
                else
                {
                    input_wallet_name.error = true;
                    text_error = checkWalletName;
                }
            }
            else _seedField.error = true;
        }

        ColumnLayout
        {
            id: column_layout

            anchors.centerIn: parent

            spacing: Style.rowSpacing
            RowLayout
            {
                Layout.fillWidth: true
                spacing: 10
                SquareButton
                {
                    icon.source: Qaterial.Icons.chevronLeft
                    Layout.alignment: Qt.AlignVCenter
                    onClicked:
                    {
                        if (currentStep === 0)
                        {
                            reset();
                            backClicked();
                        }
                        else
                        {
                            if (text_error !== "") text_error = "";
                            currentStep--;
                        }
                    }
                }

                DefaultText
                {
                    font: DexTypo.head6
                    Layout.fillWidth: true
                    rightPadding: 20
                    wrapMode: Label.Wrap
                    text_value: if (currentStep === 0) qsTr("Import wallet - Setup")
                    else if (currentStep === 1) qsTr("Import wallet - Choose password")
                    Layout.alignment: Qt.AlignVCenter
                }

            }



            ModalLoader
            {
                id: eula_modal
                sourceComponent: EulaModal
                {
                    onConfirm: () =>
                    {
                        if (onClickedConfirm(_inputPassword.field.text, _seedField.field.text, input_wallet_name.field.text))
                            reset();
                    }
                }
            }
            ColumnLayout
            {
                visible: currentStep === 0
                Layout.preferredWidth: 450
                spacing: Style.rowSpacing

                DexAppTextField
                {
                    id: input_wallet_name
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    opacity: enabled ? 1 : .5
                    background.radius: 25
                    field.font: DexTypo.body2
                    field.horizontalAlignment: Qt.AlignLeft
                    field.leftPadding: 75
                    field.placeholderText: qsTr("Wallet Name")
                    field.onAccepted: tryPassLevel1()
                    field.onTextChanged: text_error = ""
                    DefaultRectangle
                    {
                        x: 5
                        height: 40
                        width: 60
                        radius: 20
                        color: Dex.CurrentTheme.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                        Qaterial.ColorIcon
                        {
                            anchors.centerIn: parent
                            iconSize: 19
                            source: Qaterial.Icons.wallet
                            color: Dex.CurrentTheme.foregroundColor
                        }
                    }
                }

                DexAppPasswordField
                {
                    id: _seedField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    leftIcon: Qaterial.Icons.fileKey
                    field.font: DexTypo.body2
                    field.placeholderText: qsTr('Enter seed')
                    field.onAccepted: tryPassLevel1()
                    field.onTextChanged:
                    {
                        field.text = field.text.replace("\n", "")
                        field.cursorPosition = field.length
                    }

                    function isValid()
                    {
                        if (!allow_custom_seed.checked) _seedField.field.text = _seedField.field.text.trim().toLowerCase();
                        _seedField.field.text = _seedField.field.text.replace(/[^\w\s]/gi, '');
                        return allow_custom_seed.checked || API.app.wallet_mgr.mnemonic_validate(_seedField.field.text);
                    }
                }

                DefaultText
                {
                    id: _seedError
                    visible: _seedField.error
                    text: qsTr("BIP39 seed validation failed, try again or select 'Allow custom seed'")
                    color: Dex.CurrentTheme.noColor
                    Layout.preferredWidth: parent.width - 40
                    wrapMode: DexLabel.Wrap
                    font: DexTypo.body2
                }

                DefaultCheckBox
                {
                    id: allow_custom_seed
                    text: qsTr("Allow custom seed")
                    leftPadding: 15
                    onToggled:
                    {
                        if (allow_custom_seed.checked)
                        {
                            let dialog = app.getText(
                            {
                                title: qsTr("<strong>Allow custom seed</strong>"),
                                text: qsTr("Custom seed phrases might be less secure and easier to crack than a generated BIP39 compliant seed phrase or private key (WIF).<br><br>To confirm you understand the risk and know what you are doing, type <strong>'I understand'</strong> in the box below."),
                                placeholderText: qsTr("I understand"),
                                standardButtons: Dialog.Yes | Dialog.Cancel,
                                validator: (text) =>
                                {
                                    return text === qsTr("I understand")
                                },
                                yesButtonText: qsTr("Enable"),
                                onAccepted: function()
                                {
                                    allow_custom_seed.checked = true;
                                    dialog.close()
                                },
                                onRejected: function()
                                {
                                    allow_custom_seed.checked = false;
                                }
                            })
                        }
                        else allow_custom_seed.checked = false;
                    }
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                }

                RowLayout
                {
                    Layout.preferredWidth: 400
                    spacing: Style.buttonSpacing

                    Item
                    {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 10
                    }


                    DexGradientAppButton
                    {
                        id: nextButton
                        enabled: input_wallet_name.field.text !== "" && _seedField.field.text !== ""
                        onClicked: tryPassLevel1()
                        radius: 20

                        text: qsTr("Next")
                        leftPadding: 5
                        rightPadding: 5
                        padding: 16
                        opacity: enabled ? 1 : .7
                        Layout.preferredHeight: 45
                        iconSourceRight: Qaterial.Icons.arrowRight
                    }
                }

                DefaultText
                {
                    text_value: text_error
                    color: Dex.CurrentTheme.noColor
                    visible: text !== ''
                }
            }


            ColumnLayout
            {
                visible: currentStep === 1
                Layout.preferredWidth: 460
                Layout.rightMargin: 5
                spacing: Style.rowSpacing
                DexAppPasswordField
                {
                    id: _inputPassword
                    field.font: DexTypo.body2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    field.onAccepted: trySubmit()
                }

                DexKeyChecker
                {
                    id: _keyChecker
                    double_validation: true
                    field: _inputPassword.field
                    match_password: _inputPasswordConfirm.field.text
                    Layout.leftMargin: 20
                }

                DexAppPasswordField
                {
                    id: _inputPasswordConfirm
                    field.font: DexTypo.body2
                    field.placeholderText: qsTr("Enter the same password to confirm")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    field.onAccepted: trySubmit()
                }

                Item
                {
                    Layout.fillWidth: true
                }

                RowLayout
                {
                    Layout.preferredWidth: 400
                    Item
                    {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 10
                    }


                    DexGradientAppButton
                    {
                        id: submit_button
                        enabled: _keyChecker.isValid()
                        text: qsTr("Continue")
                        radius: 20
                        leftPadding: 5
                        rightPadding: 5
                        padding: 16
                        opacity: enabled ? 1 : .7
                        Layout.preferredHeight: 45
                        iconSourceRight: Qaterial.Icons.arrowRight
                        onClicked: trySubmit()
                    }
                }

                DefaultText
                {
                    text_value: text_error
                    color: Dex.CurrentTheme.noColor
                    visible: text !== ''
                }
            }
        }
    }
}