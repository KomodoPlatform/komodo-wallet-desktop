import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextFieldWithTitle {
    id: input_wallet_name
    title: qsTr("Wallet Name")
    field.placeholderText: qsTr("Enter the name of your wallet here")
    field.validator: RegExpValidator { regExp: /\w+/ }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
