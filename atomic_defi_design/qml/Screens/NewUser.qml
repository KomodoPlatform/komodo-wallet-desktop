import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"

SetupPage {
    id: new_user

    // Override
    property var onClickedBack: () => {}
    property var postCreateSuccess: () => {}

    property string current_mnemonic
    property string text_error
    property string guess_text_error

    property bool form_is_filled: false
    property int current_word_idx: 0
    property int guess_count: 1

    Component.onCompleted: onOpened()

    function onOpened() {
        current_mnemonic = API.app.get_mnemonic()
    }

    function getWords() {
        return current_mnemonic.split(" ")
    }

    function setRandomGuessWord() {
        const prev_idx = current_word_idx
        while(current_word_idx === prev_idx)
            current_word_idx = General.getRandomInt(0, getWords().length - 1)
    }

    function validGuessField(field) {
        return field.acceptableInput
    }

    function submitGuess(field) {
        if(validGuessField(field)) {
            // Check if it's correct
            if(field.text === getWords()[current_word_idx]) {
                if(isFinalGuess()) {
                    return true
                }
                else {
                    ++guess_count
                    setRandomGuessWord()
                }
                field.text = ""
                guess_text_error = ""
            }
            else {
                guess_text_error = qsTr("Wrong word, please check again")
            }
        }

        return false
    }

    function isFinalGuess() {
        return guess_count === 3
    }

    // Local
    function reset() {
        current_mnemonic = ""
        text_error = ""

        form_is_filled = false
        guess_text_error = ""
        guess_count = 1
    }

    function onClickedCreate(password, generated_seed, wallet_name) {
        if(API.app.wallet_mgr.create(password, generated_seed, wallet_name)) {
            console.log("Success: Create wallet")
            selected_wallet_name = wallet_name
            postCreateSuccess()
            return true
        }
        else {
            console.log("Failed: Create wallet")
            text_error = qsTr("Failed to create a wallet")
            return false
        }
    }

    image_scale: 0.7
    // Removed the image for now, no space
    //image_path: General.image_path + (form_is_filled ? "settings-seed.svg" : "setup-welcome-wallet.svg")

    content: ColumnLayout {
        width: 600
        spacing: Style.rowSpacing

        DefaultText {
            text_value: qsTr("New Wallet")
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        function reset() {
            new_user.reset()
            input_wallet_name.reset()
            input_confirm_seed.reset()
            input_password.reset()
            input_seed_word.field.text = ""
        }

        function completeForm() {
            if(!continue_button.enabled) return

            text_error = General.checkIfWalletExists(input_wallet_name.field.text)
            if(text_error !== "") return

            input_seed_word.field.text = ""
            guess_text_error = ""
            guess_count = 1
            setRandomGuessWord()

            form_is_filled = true
        }

        function tryGuess() {
            // Open EULA if it's the final one
            if(submitGuess(input_seed_word.field)) eula_modal.open()
        }

        ModalLoader {
            id: eula_modal
            sourceComponent: EulaModal {
                onConfirm: () => {
                   if(onClickedCreate(input_password.field.text,
                                       input_generated_seed.field.text,
                                       input_wallet_name.field.text)) reset()
                }
            }
        }


        // First page, fill the form
        ColumnLayout {
            visible: !form_is_filled
            spacing: Style.rowSpacing

            WalletNameField {
                id: input_wallet_name
                field.onAccepted: completeForm()
            }

            TextAreaWithTitle {
                id: input_generated_seed
                title: qsTr("Generated Seed")
                field.text: current_mnemonic
                field.readOnly: true
                copyable: true
                onReturn: completeForm
            }

            FloatingBackground {
                Layout.topMargin: 10
                Layout.bottomMargin: Layout.topMargin
                Layout.fillWidth: true
                color: Style.colorRed3
                height: warning_texts.height + 20

                Column {
                    id: warning_texts

                    anchors.centerIn: parent
                    width: parent.width

                    spacing: 10

                    DefaultText {
                        width: parent.width - 40
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: qsTr("Important: Back up your seed phrase before proceeding!")
                    }

                    DefaultText {
                        width: parent.width - 40
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: qsTr("We recommend storing it offline.")
                        font.pixelSize: Style.textSizeSmall4
                        color: Style.colorWhite4
                    }
                }
            }

            TextAreaWithTitle {
                id: input_confirm_seed
                title: qsTr("Confirm Seed")
                field.placeholderText: qsTr("Enter the generated seed here")
                onReturn: completeForm
            }

            PasswordForm {
                id: input_password

                field.onAccepted: completeForm()
                confirm_field.onAccepted: completeForm()
            }

            RowLayout {
                spacing: Style.buttonSpacing

                DefaultButton {
                    Layout.fillWidth: true
                    text: qsTr("Back")
                    onClicked: {
                        reset()
                        onClickedBack()
                    }
                }

                PrimaryButton {
                    id: continue_button
                    Layout.fillWidth: true
                    text: qsTr("Continue")
                    onClicked: completeForm()
                    enabled:    // Fields are not empty
                                input_wallet_name.field.acceptableInput === true &&
                                input_password.isValid() &&
                                // Correct confirm fields
                                input_generated_seed.field.text === input_confirm_seed.field.text
                }
            }

            DefaultText {
                text_value: text_error
                color: Style.colorRed
                visible: text !== ''
            }
        }


        // Second page, write the seed word
        ColumnLayout {
            visible: form_is_filled

            FloatingBackground {
                Layout.topMargin: 10
                Layout.bottomMargin: Layout.topMargin
                Layout.fillWidth: true
                height: 160

                Column {
                    id: warning_texts_2

                    anchors.centerIn: parent
                    width: parent.width

                    spacing: 30

                    DefaultText {
                        width: parent.width - 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: qsTr("Let's double check your seed phrase")
                    }

                    DefaultText {
                        width: parent.width - 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: qsTr("Your seed phrase is important - that's why we like to make sure it's correct. We'll ask you three different questions about your seed phrase to make sure you'll be able to easily restore your wallet whenever you want.")
                        font.pixelSize: Style.textSizeSmall4
                        color: Style.colorWhite4
                    }
                }
            }


            TextFieldWithTitle {
                id: input_seed_word
                title: qsTr("What's the %n. word in your seed phrase?", "", current_word_idx + 1)
                field.placeholderText: qsTr("Enter the %n. word", "", current_word_idx + 1)
                field.validator: RegExpValidator { regExp: /[a-z]+/ }
                field.onAccepted: tryGuess()
            }

            RowLayout {
                DefaultButton {
                    Layout.fillWidth: true
                    text: qsTr("Go back and check again")
                    onClicked: form_is_filled = false
                }

                PrimaryButton {
                    id: submit_button
                    Layout.fillWidth: true
                    text: qsTr("Continue")
                    onClicked: tryGuess()
                    enabled: validGuessField(input_seed_word.field)
                }
            }

            DefaultText {
                text_value: guess_text_error
                color: Style.colorRed
                visible: text !== ''
            }
        }
    }
}
