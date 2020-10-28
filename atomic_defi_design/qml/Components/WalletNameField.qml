import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15


import "../Constants"
TextFieldWithTitle {
    id: input_wallet_name
    title: qsTr("Wallet Name")
    field.placeholderText: qsTr("Enter the name of your wallet here")
    field.validator: RegExpValidator { regExp: /[a-zA-Z0-9]+/ }

    required: true

    function reset() {
        field.text = ''
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
