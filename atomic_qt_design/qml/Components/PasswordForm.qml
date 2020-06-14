import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ColumnLayout {
    id: form
    spacing: Style.rowSpacing

    property alias field: input_password.field
    property alias confirm_field: input_confirm_password.field
    property bool confirm: true
    property bool new_password: true

    function isValid() {
        const valid_pw = input_password.isValid()
        if(!confirm) return valid_pw

        const valid_cpw = input_confirm_password.isValid()
        const matching = input_password.field.text === input_confirm_password.field.text
        return valid_pw && valid_cpw && matching

    }

    function reset() {
        input_password.field.text = ""
        input_confirm_password.field.text = ""
    }

    PasswordField {
        id: input_password
        new_password: form.new_password
        hide_hint: !confirm
        match_password: input_confirm_password.field.text
    }

    PasswordField {
        hide_hint: true
        visible: confirm
        id: input_confirm_password
        title: API.get().empty_string + (qsTr("Confirm Password"))
        field.placeholderText: API.get().empty_string + (qsTr("Enter the same password to confirm"))
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
