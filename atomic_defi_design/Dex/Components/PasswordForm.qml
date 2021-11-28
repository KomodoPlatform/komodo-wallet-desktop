import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0

ColumnLayout {
    id: form
    spacing: Style.rowSpacing

    property alias field: input_password.field
    property alias confirm_field: input_confirm_password.field
    property alias field_title: input_password.title
    property alias confirm_field_title: input_confirm_password.title
    property bool confirm: true
    property bool new_password: true
    property bool high_security: true

    function isValid() {
        const valid_pw = input_password.isValid()
        if(!confirm) return valid_pw

        const valid_cpw = input_confirm_password.isValid()
        const matching = input_password.field.text === input_confirm_password.field.text
        return valid_pw && valid_cpw && matching

    }

    function reset() {
        input_password.reset()
        input_confirm_password.reset()
    }

    PasswordField {
        id: input_password
        new_password: form.new_password
        hide_hint: !confirm
        title: qsTr("Password")
        match_password: input_confirm_password.field.text
        high_security: form.high_security
    }

    PasswordField {
        hide_hint: true
        visible: confirm
        id: input_confirm_password
        title: qsTr("Confirm Password")
        field.placeholderText: qsTr("Enter the same password to confirm")
        high_security: form.high_security
    }
}
