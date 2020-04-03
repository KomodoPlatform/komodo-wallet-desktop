import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: pw.title
    property alias field: pw.field
    property bool hide_hint: false

    function isValid() {
        return pw.field.acceptableInput && RegExp(API.get().get_regex_password_policy()).test(pw.field.text)
    }

    function hasEnoughCharacters() {
        return pw.field.acceptableInput && RegExp(/\S{16,}/).test(pw.field.text)
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
        field.placeholderText: API.get().empty_string + (qsTr("Enter a password for your wallet"))
        field.validator: RegExpValidator { regExp: /\S+/ }
    }

    ColumnLayout {
        spacing: -Style.textSizeSmall3*0.3

        visible: !hide_hint
        Layout.fillWidth: true

        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (Style.listItemPrefix + qsTr("At least 1 lowercase alphabetical character"))
        }
        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (Style.listItemPrefix + qsTr("At least 1 uppercase alphabetical character"))
        }
        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (Style.listItemPrefix + qsTr("At least 1 numeric character"))
        }
        DefaultText {
            font.pixelSize: Style.textSizeSmall3
            text: API.get().empty_string + (Style.listItemPrefix + qsTr("At least 1 special character (eg. !@#$%)"))
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
