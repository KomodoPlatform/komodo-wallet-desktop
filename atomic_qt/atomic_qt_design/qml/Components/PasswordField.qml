import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

TextFieldWithTitle {
    hidable: true
    title: qsTr("Password")
    field.placeholderText: qsTr("Enter a password for your wallet")
    field.validator: RegExpValidator { regExp: /\S+/ }
    function isValid() {
        return field.acceptableInput && RegExp(API.get().get_regex_password_policy()).test(field.text)
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
