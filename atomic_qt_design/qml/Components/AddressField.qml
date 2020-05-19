import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextFieldWithTitle {
    field.validator: RegExpValidator {
        regExp: /[a-zA-Z0-9 \t]{25,100}/
    }
    field.onTextChanged: {
        if(field.text.indexOf(' ') !== -1 || field.text.indexOf('\t') !== -1) {
            field.text = field.text.replace(/[ \t]/, '')
        }
    }
}
