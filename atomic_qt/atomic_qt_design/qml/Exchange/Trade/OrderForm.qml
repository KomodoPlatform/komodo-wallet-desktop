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

    // Local
    function sellCoin(base, rel, price, volume) {
        console.log(`Selling ${volume} ${base} for ${price} ${rel} each`)
    }

    function buyCoin(base, rel, price, volume) {
        console.log(`Buying ${volume} ${base} for ${price} ${rel} each`)
    }

    function hasEnoughFunds(sell, base, rel, price, volume) {
        if(sell) {
            if(volume === "") return true
            return API.get().do_i_have_enough_funds(base, volume)
        }
        else {
            if(price === "") return true
            const needed_amount = parseFloat(price) * parseFloat(volume)
            return API.get().do_i_have_enough_funds(rel, needed_amount)
        }
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
            Layout.leftMargin: 10
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: Layout.leftMargin
            title: qsTr("Volume")
            field.placeholderText: qsTr("Enter the amount")
        }

        // Price
        AmountField {
            id: input_price
            Layout.leftMargin: 10
            Layout.rightMargin: Layout.leftMargin
            title: qsTr("Price")
            field.placeholderText: qsTr("Enter the price")
        }

        DefaultText {
            Layout.leftMargin: 10
            Layout.rightMargin: Layout.leftMargin

            color: Style.colorRed

            text: qsTr("Not enough funds.") + "\n" + qsTr("You have ") + API.get().get_balance(sell ? base : rel) + " " + (sell ? base : rel)
            wrapMode: Text.Wrap
            visible: !hasEnoughFunds(sell, base, rel, input_price.field.text, input_volume.field.text)
            Layout.maximumWidth: parent.width - Layout.leftMargin * 2
        }

        // Action button
        Button {
            Layout.leftMargin: 10
            Layout.rightMargin: Layout.leftMargin
            Layout.fillWidth: true

            text: sell ? qsTr("Sell") : qsTr("Buy")
            enabled: input_price.field.text !== "" &&
                     input_volume.field.text !== "" &&
                     parseFloat(input_price.field.text) > 0 &&
                     parseFloat(input_volume.field.text) > 0 &&
                     hasEnoughFunds(sell, base, rel, input_price.field.text, input_volume.field.text)
            onClicked: sell ? sellCoin(base, rel, input_price.field.text, input_volume.field.text) : buyCoin(base, rel, input_price.field.text, input_volume.field.text)
        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
