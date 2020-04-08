import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
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


    function submitGuess(field, password, generated_seed, confirm_seed, wallet_name) {
        if(validGuessField(field)) {
            // Check if it's correct
            if(field.text === getWords()[current_word_idx]) {
                if(isFinalGuess()) {
                    onClickedCreate(password, generated_seed, confirm_seed, wallet_name)
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
                guess_text_error = API.get().empty_string + (qsTr("Wrong word, please check again"))
            }
        }

        return false
    }

    function isFinalGuess() {
        return guess_count === 3
    }

    function onOpened() {
        current_mnemonic = API.get().get_mnemonic()
    }

    // Local
    function reset() {
        current_mnemonic = ""
        text_error = ""

        form_is_filled = false
        guess_text_error = ""
        guess_count = 1
    }

    function onClickedCreate(password, generated_seed, confirm_seed, wallet_name) {
        if(API.get().create(password, generated_seed, wallet_name)) {
            console.log("Success: Create wallet")
            postCreateSuccess()
            return true
        }
        else {
            console.log("Failed: Create wallet")
            text_error = API.get().empty_string + (qsTr("Failed to create a wallet"))
            return false
        }
    }

    image_scale: 0.7
    image_path: General.image_path + "setup-welcome-wallet.svg"
    title: API.get().empty_string + (qsTr("New User"))

    content: ColumnLayout {
        width: 600

        function reset() {
            new_user.reset()
            input_wallet_name.reset()
            input_confirm_seed.reset()
            input_password.reset()
            input_seed_word.field.text = ""
        }

        function completeForm() {
            if(!continue_button.enabled) return

            input_seed_word.field.text = ""
            guess_text_error = ""
            guess_count = 1
            setRandomGuessWord()

            form_is_filled = true
        }

        function tryGuess() {
            if(submitGuess(input_seed_word.field,
                           input_password.field.text,
                           input_generated_seed.field.text,
                           input_confirm_seed.field.text,
                           input_wallet_name.field.text)) reset()
        }

        // First page, fill the form
        ColumnLayout {
            visible: !form_is_filled

            WalletNameField {
                id: input_wallet_name
                field.onAccepted: completeForm()
            }

            Rectangle {
                Layout.topMargin: 10
                Layout.bottomMargin: Layout.topMargin
                Layout.fillWidth: true
                color: Style.colorRed3
                radius: 10
                height: warning_texts.height + 20

                ColumnLayout {
                    id: warning_texts

                    anchors.centerIn: parent

                    DefaultText {
                        Layout.alignment: Qt.AlignHCenter
                        text: API.get().empty_string + (qsTr("Important: Back up your seed phrase before proceeding!"))
                    }

                    DefaultText {
                        Layout.alignment: Qt.AlignHCenter
                        text: API.get().empty_string + (qsTr("We recommend storing it offline."))
                        font.pixelSize: Style.textSizeSmall4
                        color: Style.colorWhite4
                    }
                }
            }

            TextAreaWithTitle {
                id: input_generated_seed
                title: API.get().empty_string + (qsTr("Generated Seed"))
                field.text: current_mnemonic
                field.readOnly: true
                copyable: true
                onReturn: completeForm
            }

            TextAreaWithTitle {
                id: input_confirm_seed
                title: API.get().empty_string + (qsTr("Confirm Seed"))
                field.placeholderText: API.get().empty_string + (qsTr("Enter the generated seed here"))
                onReturn: completeForm
            }

            PasswordForm {
                id: input_password

                field.onAccepted: completeForm()
                confirm_field.onAccepted: completeForm()
            }

            RowLayout {
                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Back"))
                    onClicked: {
                        reset()
                        onClickedBack()
                    }
                }

                PrimaryButton {
                    id: continue_button
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Continue"))
                    onClicked: completeForm()
                    enabled:    // Fields are not empty
                                input_wallet_name.field.acceptableInput === true &&
                                input_password.isValid() &&
                                // Correct confirm fields
                                input_generated_seed.field.text === input_confirm_seed.field.text
                }
            }

            DefaultText {
                text: API.get().empty_string + (text_error)
                color: Style.colorRed
                visible: text !== ''
            }
        }


        // Second page, write the seed word
        ColumnLayout {
            visible: form_is_filled

            Rectangle {
                Layout.topMargin: 10
                Layout.bottomMargin: Layout.topMargin
                Layout.fillWidth: true
                color: Style.colorTheme7
                radius: 10
                height: warning_texts_2.height + 20

                ColumnLayout {
                    id: warning_texts_2

                    anchors.centerIn: parent

                    DefaultText {
                        Layout.alignment: Qt.AlignHCenter
                        text: API.get().empty_string + (qsTr("Let's double check your seed phrase"))
                    }

                    DefaultText {
                        Layout.alignment: Qt.AlignHCenter
                        text: API.get().empty_string + (qsTr("Your seed phrase is important - that's why we like to make sure it's correct. We'll ask you three different questions about your seed phrase to make sure you'll be able to easily restore your wallet whenever you want."))
                        font.pixelSize: Style.textSizeSmall4
                        color: Style.colorWhite4
                    }
                }
            }


            TextFieldWithTitle {
                id: input_seed_word
                title: API.get().empty_string + (qsTr("What's the %n. word in your seed phrase?", "", current_word_idx + 1))
                field.placeholderText: API.get().empty_string + (qsTr("Enter the %n. word", "", current_word_idx + 1))
                field.validator: RegExpValidator { regExp: /[a-z]+/ }
                field.onAccepted: tryGuess()
            }

            RowLayout {
                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Go back and check again"))
                    onClicked: form_is_filled = false
                }

                PrimaryButton {
                    id: submit_button
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Continue"))
                    onClicked: tryGuess()
                    enabled: validGuessField(input_seed_word.field)
                }
            }

            DefaultText {
                text: API.get().empty_string + (guess_text_error)
                color: Style.colorRed
                visible: text !== ''
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
