import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12


TextFieldWithTitle {
    field.validator: RegExpValidator {
        regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/
    }
}
