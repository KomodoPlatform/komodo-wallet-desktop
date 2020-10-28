import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15


TextFieldWithTitle {
    field.validator: RegExpValidator {
        regExp: /[0-9]+/
    }
}
