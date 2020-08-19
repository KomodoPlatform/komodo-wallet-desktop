import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12


DefaultTextField {
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
