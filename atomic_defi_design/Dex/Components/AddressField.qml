import QtQuick 2.15

DexTextField {
    readonly property int max_length: 50

    validator: RegExpValidator {
        regExp: /[a-zA-Z0-9 \t]{25,50}/
    }
    onTextChanged: {
        if(text.indexOf(' ') !== -1 || text.indexOf('\t') !== -1) {
            text = text.replace(/[ \t]/, '')
        }
        if(text.length > max_length) {
            text = text.substring(0, max_length)
        }
    }
}
