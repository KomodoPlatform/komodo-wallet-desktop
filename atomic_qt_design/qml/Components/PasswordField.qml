import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: pw.title
    property alias field: pw.field
    property bool hide_hint: false
    property bool new_password: true

    function isValid() {
        return pw.field.acceptableInput && RegExp(General.reg_pass_valid).test(pw.field.text)
    }

    function hasEnoughUppercaseCharacters() {
        return pw.field.acceptableInput && RegExp(General.reg_pass_uppercase).test(pw.field.text)
    }

    function hasEnoughLowercaseCharacters() {
        return pw.field.acceptableInput && RegExp(General.reg_pass_lowercase).test(pw.field.text)
    }

    function hasEnoughNumericCharacters() {
        return pw.field.acceptableInput && RegExp(General.reg_pass_numeric).test(pw.field.text)
    }

    function hasEnoughSpecialCharacters() {
        return pw.field.acceptableInput && RegExp(General.reg_pass_special).test(pw.field.text)
    }

    function hasEnoughCharacters() {
        return pw.field.acceptableInput && RegExp(General.reg_pass_count).test(pw.field.text)
    }

    function hintColor(valid) {
        return valid ? Style.colorGreen : Style.colorRed
    }

    function hintPrefix(valid) {
        return " " + (valid ? Style.successCharacter : Style.failureCharacter) + "   "
    }

    TextFieldWithTitle {
        id: pw
        hidable: true
        title: API.get().empty_string + (qsTr("Password"))
        field.placeholderText: API.get().empty_string + (new_password ? qsTr("Enter a password for your wallet") : qsTr("Enter the password of your wallet"))
        field.validator: RegExpValidator { regExp: General.reg_pass_input }
    }

    ColumnLayout {
        spacing: -Style.textSizeSmall3*0.3

        visible: !hide_hint
        Layout.fillWidth: true

        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (hintPrefix(hasEnoughLowercaseCharacters()) + qsTr("At least 1 lowercase alphabetical character"))
            color: hintColor(hasEnoughLowercaseCharacters())
        }
        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (hintPrefix(hasEnoughUppercaseCharacters()) + qsTr("At least 1 uppercase alphabetical character"))
            color: hintColor(hasEnoughUppercaseCharacters())
        }
        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (hintPrefix(hasEnoughNumericCharacters()) + qsTr("At least 1 numeric character"))
            color: hintColor(hasEnoughNumericCharacters())
        }
        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (hintPrefix(hasEnoughSpecialCharacters()) + qsTr("At least 1 special character (eg. !@#$%)"))
            color: hintColor(hasEnoughSpecialCharacters())
        }
        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (hintPrefix(hasEnoughCharacters()) + qsTr("At least 16 characters"))
            color: hintColor(hasEnoughCharacters())
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
