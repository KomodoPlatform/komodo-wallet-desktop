import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    property string base
    property string rel
    property bool sell

    // Local
    property string action_result

    function reset(reset_result=true) {
        if(reset_result) action_result = ""
        input_price.field.text = ""
        input_volume.field.text = ""
    }

    function onOrderSuccess() {
        reset(false)
        refresh_timer.restart()
        stop_refreshing.restart()
    }

    Timer {
        id: refresh_timer
        repeat: true
        interval: 500
        triggeredOnStart: true
        onTriggered: API.get().refresh_orders_and_swaps()
    }

    Timer {
        id: stop_refreshing
        interval: 5000
        onTriggered: refresh_timer.stop()
    }

    function sellCoin(base, rel, price, volume) {
        action_result = API.get().place_sell_order(base, rel, price, volume) ? "success" : "error"
        if(action_result === "success") onOrderSuccess()
    }

    function buyCoin(base, rel, price, volume) {
        action_result = API.get().place_buy_order(base, rel, price, volume) ? "success" : "error"
        if(action_result === "success") onOrderSuccess()
    }

    function amountToReceive(sell, base, rel, price, volume) {
        return sell ? (parseFloat(price) * parseFloat(volume)) + " " + rel : volume + " " + base
    }

    function fieldsAreFilled() {
        return input_price.field.text !== "" &&
                input_volume.field.text !== "" &&
                parseFloat(input_price.field.text) > 0 &&
                parseFloat(input_volume.field.text) > 0
    }

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    ColumnLayout {
        width: parent.width

        RowLayout {
            DefaultText {
                id: title

                Layout.leftMargin: 15
                Layout.topMargin: 10
                Layout.bottomMargin: 5

                text: (sell ? qsTr("Sell") : qsTr("Buy")) + " " + base
                font.pointSize: Style.textSize2
            }

            Image {
                source: General.coinIcon(base)
                Layout.preferredWidth: 32
                Layout.preferredHeight: Layout.preferredWidth
            }
            DefaultText {
                text: base === "" ? "" : "(" + API.get().get_balance(base) + ")"
                font.pointSize: Style.textSize
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        // Volume
        AmountField {
            id: input_volume
            Layout.leftMargin: title.Layout.leftMargin
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: Layout.leftMargin
            title: qsTr("Volume")
            field.placeholderText: qsTr("Enter the amount")
        }

        // Price
        AmountField {
            id: input_price
            Layout.leftMargin: input_volume.Layout.leftMargin
            Layout.rightMargin: Layout.leftMargin
            title: qsTr("Price")
            field.placeholderText: qsTr("Enter the price")
        }

        // Not enough funds error
        DefaultText {
            Layout.leftMargin: input_volume.Layout.leftMargin
            Layout.rightMargin: Layout.leftMargin
            Layout.maximumWidth: parent.width - Layout.leftMargin * 2
            wrapMode: Text.Wrap
            visible: !General.hasEnoughFunds(sell, base, rel, input_price.field.text, input_volume.field.text)

            color: Style.colorRed

            text: qsTr("Not enough funds.") + "\n" + qsTr("You have %1", "AMT TICKER").arg(General.formatCrypto("", API.get().get_balance(sell ? base : rel),sell ? base : rel))
        }

        // Action button
        PrimaryButton {
            id: action_button
            Layout.leftMargin: input_volume.Layout.leftMargin
            Layout.rightMargin: Layout.leftMargin
            Layout.fillWidth: true

            text: sell ? qsTr("Sell") : qsTr("Buy")
            enabled: fieldsAreFilled() && General.hasEnoughFunds(sell, base, rel, input_price.field.text, input_volume.field.text)
            onClicked: sell ? sellCoin(base, rel, input_price.field.text, input_volume.field.text) : buyCoin(base, rel, input_price.field.text, input_volume.field.text)
        }

        // Amount to receive
        DefaultText {
            Layout.leftMargin: input_volume.Layout.leftMargin
            Layout.rightMargin: Layout.leftMargin
            Layout.maximumWidth: parent.width - Layout.leftMargin * 2
            wrapMode: Text.Wrap
            visible: action_button.enabled

            color: Style.colorGreen

            text: qsTr("You'll receive", "AMT TICKER") + ":" + "\n" + amountToReceive(sell, base, rel, input_price.field.text, input_volume.field.text)
        }

        // Result
        DefaultText {
            Layout.leftMargin: input_volume.Layout.leftMargin
            Layout.rightMargin: Layout.leftMargin
            Layout.maximumWidth: parent.width - Layout.leftMargin * 2
            wrapMode: Text.Wrap
            visible: action_result !== ""

            color: action_result === "success" ? Style.colorGreen : Style.colorRed

            text: action_result === "success" ? qsTr("Successfully placed the order!") : qsTr("Failed to place the order.")
        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
