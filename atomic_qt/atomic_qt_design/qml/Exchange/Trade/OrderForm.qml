import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    property string base
    property string rel

    property bool sell

    function sellCoin(base, rel, price, volume) {
        console.log(`Selling ${volume} ${base} for ${price} ${rel} each`)
    }

    function buyCoin(base, rel, price, volume) {
        console.log(`Buying ${volume} ${base} for ${price} ${rel} each`)
    }

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    ColumnLayout {
        width: parent.width

        DefaultText {
            id: title

            Layout.leftMargin: 15
            Layout.topMargin: 10
            Layout.bottomMargin: 5

            text: (sell ? qsTr("Sell") : qsTr("Buy")) + " " + base + qsTr(" for ") + rel
            font.pointSize: Style.textSize2
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        // Volume
        AmountField {
            id: input_volume
            Layout.topMargin: 10
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            title: qsTr("Volume")
            field.placeholderText: qsTr("Enter the amount")
        }

        // Price
        AmountField {
            id: input_price
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            title: qsTr("Price")
            field.placeholderText: qsTr("Enter the price")
        }

        // Action button
        Button {
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.fillWidth: true

            text: sell ? qsTr("Sell") : qsTr("Buy")
            enabled: input_price.field.text !== "" &&
                     input_volume.field.text !== "" &&
                     parseFloat(input_price.field.text) > 0 &&
                     parseFloat(input_volume.field.text) > 0
            onClicked: sell ? sellCoin(base, rel, input_price.field.text, input_volume.field.text) : buyCoin(base, rel, input_price.field.text, input_volume.field.text)
        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
