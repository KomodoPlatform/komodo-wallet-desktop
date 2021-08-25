import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import App 1.0

SetupPage {
    id: new_user

    // Override
    signal clickedBack()
    signal postCreateSuccess()

    property string current_mnemonic
    property string text_error
    property string guess_text_error

    property bool form_is_filled: false
    property int currentStep: 0
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
        while (current_word_idx === prev_idx)
            current_word_idx = General.getRandomInt(0, getWords().length - 1)
    }

    function validGuessField(field) {
        return field.acceptableInput
    }

    function submitGuess(field) {
        if (validGuessField(field)) {
            // Check if it's correct
            if (field.text === getWords()[current_word_idx]) {
                if (isFinalGuess()) {
                    return [true, true]
                } else {
                    ++guess_count
                    setRandomGuessWord()
                }
                field.text = ""
                guess_text_error = ""
                return [true, false]
            } else {
                guess_text_error = qsTr("Wrong word, please check again")
            }
        }

        return [false, false]
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

    function shuffle(array) {
        var currentIndex = array.length,
            randomIndex;

        // While there remain elements to shuffle...
        while (0 !== currentIndex) {

            // Pick a remaining element...
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;

            // And swap it with the current element.
            [array[currentIndex], array[randomIndex]] = [
                array[randomIndex], array[currentIndex]
            ];
        }

        return array;
    }

    function getRandom4x(list, keep) {

        // remove keep
        const index = list.indexOf(keep);
        if (index > -1) {
            list.splice(index, 1);
        }

        // randomlise
        let randomList = shuffle(list)

        // set keeped word
        let newList = [randomList[0], randomList[1], randomList[2], keep]

        // randomlise again
        let finalList = shuffle(newList)

        // return final word list
        return finalList
    }

    function onClickedCreate(password, generated_seed, wallet_name) {
        if (API.app.wallet_mgr.create(password, generated_seed, wallet_name)) {
            selected_wallet_name = wallet_name
            postCreateSuccess()
            return true
        } else {
            text_error = qsTr("Failed to create a wallet")
            return false
        }
    }

    image_scale: 0.7
    // Removed the image for now, no space
    //image_path: General.image_path + (form_is_filled ? "settings-seed.svg" : "setup-welcome-wallet.svg")

    content: ColumnLayout {
        spacing: Style.rowSpacing
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Qaterial.AppBarButton {
                icon.source: Qaterial.Icons.arrowLeft
                foregroundColor: DexTheme.foregroundColor
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    if (currentStep === 0) {
                        reset()
                        clickedBack()
                    } else {
                        if (currentStep == 2) {
                            currentStep = 0
                            _inputPassword.field.text = ""
                            _inputPasswordConfirm.field.text = ""
                        } else {
                            input_seed_word.field.text = ""
                            currentStep--
                        }


                    }
                }
            }

            DexLabel {
                font: DexTypo.head6
                text_value: if (currentStep === 0) {
                    qsTr("New Wallet")
                } else if (currentStep === 1) {
                    qsTr("Confirm Seed")
                } else if (currentStep === 2) {
                    qsTr("Choose Password")
                }
                Layout.alignment: Qt.AlignVCenter
            }

        }

        Item {
            Layout.fillWidth: true
        }

        function reset() {
            new_user.reset()
            input_wallet_name.reset()
            _inputPassword.field.text = ""
            input_seed_word.field.text = ""
            input_generated_seed.text = ""
        }

        function completeForm() {
            if (!continue_button.enabled) return

            text_error = General.checkIfWalletExists(input_wallet_name.field.text)
            if (text_error !== "") return

            input_seed_word.field.text = ""
            guess_text_error = ""
            guess_count = 1
            setRandomGuessWord()

            form_is_filled = true
        }

        function tryGuess() {
            // Open EULA if it's the final one
            let sub = submitGuess(input_seed_word.field)
            if (sub[0] == true && sub[1] == true) {
                currentStep++
            } else if (sub[0] == true && sub[1] == false) {
                input_seed_word.field.text = ""
            } else {
                input_seed_word.field.text = ""
                input_seed_word.error = true
                setRandomGuessWord()
                mmo.model = getRandom4x(current_mnemonic.split(" "), getWords()[current_word_idx])
            }
        }

        ModalLoader {
            id: eula_modal
            sourceComponent: EulaModal {
                onConfirm: () => {
                    if (onClickedCreate(_inputPassword.field.text,
                            input_generated_seed.text,
                            input_wallet_name.field.text)) reset()
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
                opacity: enabled ? 1 : .5
                background.border.width: 1
                background.radius: 25
                field.onAccepted: completeForm()
                field.font: DexTypo.head6
                field.horizontalAlignment: Qt.AlignLeft
                field.leftPadding: 75
                field.placeholderText: "Wallet Name"
                field.onTextChanged: text_error = ""

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
                        source: Qaterial.Icons.wallet
                        color: DexTheme.surfaceColor
                    }

                }
            }
            DexRectangle {
                Layout.topMargin: 10
                Layout.bottomMargin: Layout.topMargin
                Layout.fillWidth: true
                color: DexTheme.redColor
                height: warning_texts.height + 20

                Column {
                    id: warning_texts

                    anchors.centerIn: parent
                    width: parent.width

                    spacing: 10

                    DexLabel {
                        width: parent.width - 40
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: qsTr("Important: Back up your seed phrase before proceeding!")
                        color: Style.colorWhite4
                    }

                    DexLabel {
                        width: parent.width - 40
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: qsTr("We recommend storing it offline.")
                        font.pixelSize: Style.textSizeSmall4
                        color: Style.colorWhite4
                    }
                }
            }
            TextField {
                id: input_generated_seed
                visible: false
                text: current_mnemonic
            }
            Column {
                Layout.fillWidth: true
                spacing: 5
                RowLayout {
                    width: parent.width
                    DexLabel {
                        text: qsTr("Generated Seed")
                        font: DexTypo.body1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Qaterial.AppBarButton {
                        icon.source: Qaterial.Icons.contentCopy
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: {
                            input_generated_seed.selectAll()
                            input_generated_seed.copy()
                            toast.show(qsTr("Copied to Clipboard"), General.time_toast_basic_info, "", false)
                        }
                    }
                }
                Item {
                    width: parent.width
                    height: _insideFlow.height
                    Grid {
                        id: _insideFlow
                        width: parent.width
                        spacing: 10
                        Repeater {
                            model: current_mnemonic.split(" ")
                            delegate: DexRectangle {
                                width: (_insideFlow.width - 30) / 4
                                height: _insideLabel.implicitHeight + 15
                                color: DexTheme.accentColor
                                opacity: .8
                                DexLabel {
                                    id: _insideLabel
                                    text: (index + 1) + ". " + modelData
                                    font: DexTypo.body2
                                    color: DexTheme.backgroundColor
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }
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
                    enabled: input_wallet_name.field.text !== ""
                    onClicked: {
                        text_error = General.checkIfWalletExists(input_wallet_name.field.text)
                        if (text_error !== "") {
                            input_wallet_name.error = true
                            return
                        }

                        currentStep++
                        input_seed_word.field.text = ""
                        guess_count = 1
                        setRandomGuessWord()
                    }
                    radius: 20
                    opacity: enabled ? 1 : .4
                    Layout.preferredWidth: _nextRow.implicitWidth + 40
                    Layout.preferredHeight: 45
                    label.color: 'transparent'
                    Row {
                        id: _nextRow
                        anchors.centerIn: parent
                        spacing: 10
                        DexLabel {
                            text: qsTr("Next")
                            font: DexTypo.button
                            color: nextButton.foregroundColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Qaterial.ColorIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            color: nextButton.foregroundColor
                            source: Qaterial.Icons.arrowRight
                            iconSize: 14
                        }
                    }
                }
            }

            DefaultText {
                text_value: text_error
                color: DexTheme.redColor
                visible: text !== ''
            }
        }


        // Second page, write the seed word
        ColumnLayout {
            visible: currentStep === 1

            FloatingBackground {
                Layout.topMargin: 10
                Layout.bottomMargin: Layout.topMargin
                Layout.fillWidth: true
                height: 140

                Column {
                    id: warning_texts_2

                    anchors.centerIn: parent
                    width: parent.width

                    spacing: 5

                    DexLabel {
                        width: parent.width - 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        font {
                            bold: true
                        }
                        text_value: qsTr("Let's double check your seed phrase")
                    }
                    DexLabel {
                        width: parent.width - 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: qsTr("Your seed phrase is important - that's why we like to make sure it's correct. We'll ask you three different questions about your seed phrase to make sure you'll be able to easily restore your wallet whenever you want.")
                        font.pixelSize: Style.textSizeSmall4
                        color: DexTheme.foregroundColorLightColor2
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 5
                Item {
                    width: parent.width - 10
                    height: _insideFlow2.height
                    Grid {
                        id: _insideFlow2
                        width: parent.width
                        spacing: 10
                        horizontalItemAlignment: Grid.AlignHCenter
                        Repeater {
                            id: mmo
                            model: getRandom4x(current_mnemonic.split(" "), getWords()[current_word_idx])
                            delegate: DexAppButton {
                                width: (_insideFlow2.width - 30) / 4
                                text: modelData ?? ""
                                onClicked: {
                                    input_seed_word.field.text = modelData
                                    tryGuess()
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 5
            }

            DexAppTextField {
                id: input_seed_word
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                opacity: enabled ? 1 : .5
                background.border.width: 1
                background.radius: 25
                field.font: DexTypo.head6
                field.horizontalAlignment: Qt.AlignLeft
                field.leftPadding: 75
                field.placeholderText: qsTr("Enter the %n. word", "", current_word_idx + 1)
                field.validator: RegExpValidator {
                    regExp: /[a-z]+/
                }
                field.onAccepted: tryGuess()

                DexRectangle {
                    x: 5
                    height: 40
                    width: 60
                    radius: 20
                    color: DexTheme.accentColor
                    anchors.verticalCenter: parent.verticalCenter
                    DexLabel {
                        anchors.centerIn: parent
                        font: DexTypo.head6
                        color: DexTheme.backgroundColor
                        text: current_word_idx + 1
                    }

                }
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
                    id: checkForNext
                    enabled: validGuessField(input_seed_word.field)
                    opacity: enabled ? 1 : .4
                    onClicked: tryGuess()
                    radius: 20
                    Layout.preferredWidth: _nextRow3.implicitWidth + 40
                    Layout.preferredHeight: 45
                    label.color: 'transparent'
                    Row {
                        id: _nextRow3
                        anchors.centerIn: parent
                        spacing: 10
                        DexLabel {
                            text: qsTr("Check")
                            font: DexTypo.button
                            color: checkForNext.foregroundColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Qaterial.ColorIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            color: checkForNext.foregroundColor
                            source: Qaterial.Icons.check
                            iconSize: 14
                        }
                    }
                }
            }

            DefaultText {
                text_value: guess_text_error
                color: DexTheme.redColor
                visible: input_seed_word.error
                DexVisibleBehavior on visible {}
            }
        }

        ColumnLayout {
            visible: currentStep === 2
            Layout.preferredWidth: 450
            spacing: Style.rowSpacing

            DexAppPasswordField {
                id: _inputPassword
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                field.onAccepted: _keyChecker.isValid() ? eula_modal.open() : undefined
            }

            DexKeyChecker {
                id: _keyChecker
                field: _inputPassword.field
                double_validation: true
                Layout.leftMargin: 20
                match_password: _inputPasswordConfirm.field.text
            }

            DexAppPasswordField {
                id: _inputPasswordConfirm
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                field.onAccepted: _keyChecker.isValid() ? eula_modal.open() : undefined
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.preferredWidth: 400

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                }

                DexAppButton {
                    id: finalRegisterButton
                    enabled: _keyChecker.isValid()
                    opacity: enabled ? 1 : .4
                    onClicked: eula_modal.open()
                    radius: 20
                    Layout.preferredWidth: _nextRow2.implicitWidth + 40
                    Layout.preferredHeight: 45
                    label.color: 'transparent'
                    Row {
                        id: _nextRow2
                        anchors.centerIn: parent
                        spacing: 10
                        DexLabel {
                            text: qsTr("Continue")
                            font: DexTypo.button
                            color: finalRegisterButton.foregroundColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Qaterial.ColorIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: Qaterial.Icons.arrowRight
                            color: finalRegisterButton.foregroundColor
                            iconSize: 14
                        }
                    }
                }
            }

            DefaultText {
                text_value: text_error
                color: DexTheme.redColor
                visible: text !== ''
            }
        }
    }
}