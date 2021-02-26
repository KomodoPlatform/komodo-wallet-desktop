import QtQuick 2.15

TextFieldWithTitle {
    field.validator: RegExpValidator {
        regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/
    }
}
