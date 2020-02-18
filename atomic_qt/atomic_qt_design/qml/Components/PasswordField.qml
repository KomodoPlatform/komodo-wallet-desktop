import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: pw_field.title
    property alias field: pw_field.field
    property bool hide_hint: false

    TextFieldWithTitle {
        id: pw_field
        hidable: true
        title: qsTr("Password")
        field.placeholderText: qsTr("Enter a password for your wallet")
        field.validator: RegExpValidator { regExp: /\S+/ }
        function isValid() {
            return field.acceptableInput && RegExp(API.get().get_regex_password_policy()).test(field.text)
        }
    }

    ColumnLayout {
        spacing: -5

        visible: !hide_hint
        Layout.fillWidth: true

        DefaultText {
            font.pointSize: Style.textSizeSmall
            text: Style.listItemPrefix + qsTr("At least 1 lowercase alphabetical character")
        }
        DefaultText {
            font.pointSize: Style.textSizeSmall
            text: Style.listItemPrefix + qsTr("At least 1 uppercase alphabetical character")
        }
        DefaultText {
            font.pointSize: Style.textSizeSmall
            text: Style.listItemPrefix + qsTr("At least 1 numeric character")
        }
        DefaultText {
            font.pointSize: Style.textSizeSmall
            text: Style.listItemPrefix + qsTr("At least 1 special character(eg. !@#$%)")
        }
        DefaultText {
            font.pointSize: Style.textSizeSmall
            text: Style.listItemPrefix + qsTr("At least 16 characters")
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
