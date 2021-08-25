import QtQuick 2.15

TextFieldWithTitle {
    readonly property int max_length: 60


    field.onTextChanged: {
        field.text = field.text.trim()
        if (field.text.length > max_length) {
            field.text = field.text.substring(0, max_length)
        }
    }
}
