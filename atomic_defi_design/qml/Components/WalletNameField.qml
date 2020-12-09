import QtQuick 2.15

TextFieldWithTitle {
    id: input_wallet_name
    title: qsTr("Wallet Name")
    field.placeholderText: qsTr("Enter the name of your wallet here")
    field.validator: RegExpValidator { regExp: /[a-zA-Z0-9]+/ }

    required: true

    function reset() { field.text = '' }
}
