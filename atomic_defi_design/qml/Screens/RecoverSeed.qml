import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"

SetupPage {
    id: recover_seed
    // Override
    property var onClickedBack: () => {}
    property var postConfirmSuccess: () => {}
    property int currentStep: 0

    // Local
    function reset() {
        text_error = ""
    }

    function onClickedConfirm(password, seed, wallet_name) {
        if(API.app.wallet_mgr.create(password, seed, wallet_name)) {
            console.log("Success: Recover seed")
            selected_wallet_name = wallet_name
            postConfirmSuccess()
            return true
        }
        else {
            console.log("Failed: Recover seed")
            text_error = qsTr("Failed to recover the seed")
            return false
        }
    }

    property string text_error

    image_scale: 0.7

    // Removed the image for now, no space
    // image_path: General.image_path + "setup-wallet-restore-2.svg"

    content: ColumnLayout {
        width: 400
        spacing: Style.rowSpacing
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Qaterial.AppBarButton {
                icon.source: Qaterial.Icons.arrowLeft
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    if(currentStep === 0) {
                        reset()
                        onClickedBack()
                    } else {
                        currentStep--
                    }
                }
            }

            DexLabel {
                font: theme.textType.head6
                text_value: if(currentStep === 0) {
                                 qsTr("Recover wallet - Setup")
                            } else if(currentStep === 1) {
                                qsTr("Recover wallet - Choose password")
                            }
                Layout.alignment: Qt.AlignVCenter
            }

        }

        function reset() {
            recover_seed.reset()
            input_wallet_name.reset()
            _seedField.field.text = ""
            _inputPassword.field.text = ""
        }

        function trySubmit() {
            if(!submit_button.enabled) return

            text_error = General.checkIfWalletExists(input_wallet_name.field.text)
            if(text_error !== "") return

            eula_modal.open()
        }


        ModalLoader {
            id: eula_modal
            sourceComponent: EulaModal {
                onConfirm: () => {
                   if(onClickedConfirm(_inputPassword.field.text, _seedField.field.text, input_wallet_name.field.text))
                       reset()
                }
            }
        }
        ColumnLayout {
            visible: currentStep === 0
            Layout.preferredWidth: 450
            spacing: Style.rowSpacing

            DexAppTextField {
                id: input_wallet_name
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                opacity: enabled ?  1 : .5
                background.border.width: 1
                background.radius: 25 
                background.border.color: field.focus ? theme.accentColor : Style.colorBorder 
                field.font: theme.textType.head6
                field.horizontalAlignment: Qt.AlignLeft
                field.leftPadding: 75
                field.placeholderText: qsTr("Wallet Name")

                DexRectangle {
                    x: 5
                    height: 40
                    width: 60
                    radius: 20
                    color: theme.accentColor
                    anchors.verticalCenter: parent.verticalCenter
                    Qaterial.ColorIcon {
                        anchors.centerIn: parent
                        iconSize: 19
                        source: Qaterial.Icons.wallet
                        color: theme.surfaceColor
                    }

                }
            }

            
            DexLabel {
                text: qsTr("Enter seed")
                font: theme.textType.body1
            }

            DexAppTextArea {
                id: _seedField
                Layout.fillWidth: true
                height: 200
                field.onTextChanged: {
                    field.text = field.text.replace("\n","") 
                    field.cursorPosition = field.length
                }
                function isValid() { return _seedField.field.text.split(" ").length > 11 }
            }

            DefaultCheckBox {
                id: allow_custom_seed
                text: qsTr("Allow custom seed")
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
                DexAppButton {
                    id: nextButton
                    enabled: input_wallet_name.field.text !== "" && _seedField.isValid()
                    onClicked: currentStep++
                    radius: 20
                    opacity: enabled ? 1 : .4
                    backgroundColor: theme.accentColor
                    Layout.preferredWidth: _nextRow.implicitWidth + 40
                    Layout.preferredHeight: 45
                    label.color: 'transparent'
                    Row {
                        id: _nextRow
                        anchors.centerIn: parent
                        spacing: 10
                        DexLabel {
                            text: qsTr("Next")
                            font: theme.textType.button
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


        ColumnLayout {
            visible: currentStep === 1
            Layout.preferredWidth: 450
            spacing: Style.rowSpacing
            DexAppTextField {
                id: _inputPassword
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                background.border.width: 1
                background.radius: 25
                background.border.color: field.focus ? theme.accentColor : Style.colorBorder 
                field.echoMode: TextField.Password
                field.font: field.echoMode === TextField.Password ? field.text === "" ? theme.textType.body1 : theme.textType.head5 : theme.textType.head6
                field.horizontalAlignment: Qt.AlignLeft
                field.leftPadding: 75
                field.placeholderText: qsTr("Type password")
                field.onAccepted: trySubmit()
                DexRectangle {
                    x: 5
                    height: 40
                    width: 60
                    radius: 20
                    color: theme.accentColor
                    anchors.verticalCenter: parent.verticalCenter
                    Qaterial.ColorIcon {
                        anchors.centerIn: parent
                        iconSize: 19
                        source: Qaterial.Icons.keyVariant
                        color: theme.surfaceColor
                    }

                }
                Qaterial.AppBarButton {
                    opacity: .8
                    icon {
                        source: _inputPassword.field.echoMode === TextField.Password ? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
                        color: theme.accentColor
                    }
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 10
                    }
                    onClicked: {
                        if( _inputPassword.field.echoMode === TextField.Password ) { _inputPassword.field.echoMode = TextField.Normal }
                        else { _inputPassword.field.echoMode = TextField.Password }
                    }
                }
            }

            DexKeyChecker {
                id: _keyChecker
                field: _inputPassword.field
                Layout.leftMargin: 20
                match_password: _inputPasswordConfirm.field.text
            }

            DexAppTextField {
                id: _inputPasswordConfirm
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                background.border.width: 1
                background.radius: 25
                background.border.color: field.focus ? theme.accentColor : Style.colorBorder 
                field.echoMode: TextField.Password
                field.font: field.echoMode === TextField.Password ? field.text === "" ? theme.textType.body1 : theme.textType.head5 : theme.textType.head6
                field.horizontalAlignment: Qt.AlignLeft
                field.leftPadding: 75
                field.placeholderText: qsTr("Cofirm password")
                field.onAccepted: trySubmit()
                DexRectangle {
                    x: 5
                    height: 40
                    width: 60
                    radius: 20
                    color: theme.accentColor
                    anchors.verticalCenter: parent.verticalCenter
                    Qaterial.ColorIcon {
                        anchors.centerIn: parent
                        iconSize: 19
                        source: Qaterial.Icons.keyVariant
                        color: theme.surfaceColor
                    }

                }
                Qaterial.AppBarButton {
                    opacity: .8
                    icon {
                        source: _inputPasswordConfirm.field.echoMode === TextField.Password ? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
                        color: theme.accentColor
                    }
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 10
                    }
                    onClicked: {
                        if( _inputPasswordConfirm.field.echoMode === TextField.Password ) { _inputPasswordConfirm.field.echoMode = TextField.Normal }
                        else { _inputPasswordConfirm.field.echoMode = TextField.Password }
                    }
                }
            }
            RowLayout {
                Layout.preferredWidth: 400

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                }

                DexAppButton {
                    id: submit_button
                    enabled: _keyChecker.isValid()
                    opacity: enabled ? 1 : .4
                    onClicked: trySubmit()
                    radius: 20
                    backgroundColor: theme.accentColor
                    Layout.preferredWidth: _nextRow2.implicitWidth + 40
                    Layout.preferredHeight: 45
                    label.color: 'transparent'
                    Row {
                        id: _nextRow2
                        anchors.centerIn: parent
                        spacing: 10
                        DexLabel {
                            text: qsTr("Cotinue")
                            font: theme.textType.button
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

        


        DefaultText {
            text_value: text_error
            color: Style.colorRed
            visible: text !== ''
        }
    }
}
