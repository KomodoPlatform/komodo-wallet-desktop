import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextFieldWithTitle {
    field.validator: RegExpValidator {
        regExp: /[a-zA-Z0-9]{25,34}/
    }
}
