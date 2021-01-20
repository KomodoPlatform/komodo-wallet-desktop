import QtQuick 2.15

TextFieldWithTitle {
    field.validator: RegExpValidator {
        regExp: /[0-9]+/
    }
}
