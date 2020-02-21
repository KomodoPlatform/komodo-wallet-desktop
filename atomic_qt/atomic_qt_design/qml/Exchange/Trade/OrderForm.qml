import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    property alias field: input_volume.field
    property bool my_side: false

    function getVolume() {
        return input_volume.field.text === '' ? '0' :  input_volume.field.text
    }

    function getFilteredCoins() {
        return getCoins(my_side)
    }

    function getAnyAvailableCoin(filter_ticker) {
        let coins = getFilteredCoins()
        if(filter_ticker !== undefined || filter_ticker !== '')
            coins = coins.filter(c => c.ticker !== filter_ticker)
        return coins[0].ticker
    }

    function fieldsAreFilled() {
        return input_volume.field.text !== '' && parseFloat(input_volume.field.text) > 0
    }

    function isValid() {
        if(!my_side) return fieldsAreFilled()

        const ticker = getTicker()

        // Try to fit once more
        capVolume()

        return fieldsAreFilled() && API.get().do_i_have_enough_funds(ticker, input_volume.field.text)
    }

    function getTicker() {
        if(combo.currentIndex === -1) return ''

        return getFilteredCoins()[combo.currentIndex].ticker
    }

    function setTicker(ticker) {
        combo.currentIndex = getFilteredCoins().map(c => c.ticker).indexOf(ticker)

        // If it doesn't exist, pick an existing one
        if(combo.currentIndex === -1) {
            setTicker(getAnyAvailableCoin())
        }

        capVolume()
    }

    function reset() {
        if(my_side) {
            input_volume.field.text = getMaxVolume()
        }
        else {
            input_volume.field.text = ''
        }
    }

    function getMaxVolume() {
        return API.get().get_balance(getTicker())
    }

    function capVolume() {
        if(my_side && input_volume.field.acceptableInput) {
            const cap = parseFloat(getMaxVolume())
            const amt = parseFloat(input_volume.field.text)
            if(amt > cap) input_volume.field.text = cap
        }
    }

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    implicitWidth: form_layout.width
    implicitHeight: form_layout.height

    DefaultText {
        font.pointSize: Style.textSize2
        text: qsTr(my_side ? "Sell" : "Receive")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: form_layout.top
        anchors.bottomMargin: combo.Layout.rightMargin * 0.5
    }

    ColumnLayout {
        id: form_layout
        width: 300
        RowLayout {
            Image {
                Layout.leftMargin: combo.Layout.rightMargin
                source: General.coinIcon(getTicker())
                Layout.preferredWidth: 32
                Layout.preferredHeight: Layout.preferredWidth
            }

            ComboBox {
                id: combo
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.rightMargin: 15

                model: my_side ? General.getTickersAndBalances(getFilteredCoins()): General.getTickers(getFilteredCoins())
                onCurrentTextChanged: {
                    setPair()
                    if(my_side) prev_base = getTicker()
                    else prev_rel = getTicker()

                    capVolume()
                }

                MouseArea {
                    visible: !my_side
                    anchors.fill: parent
                    onClicked: {
                        order_receive_modal.open()
                    }
                }

                OrderReceiveModal {
                    id: order_receive_modal
                }

                OrderbookModal {
                    id: orderbook_modal
                }
            }
        }

        RowLayout {
            Button {
                Layout.leftMargin: combo.Layout.rightMargin
                Layout.topMargin: Layout.rightMargin
                Layout.bottomMargin: Layout.rightMargin
                visible: my_side
                text: qsTr("MAX")
                onClicked: input_volume.field.text = getMaxVolume()
            }

            AmountField {
                id: input_volume
                Layout.fillWidth: true
                Layout.rightMargin: combo.Layout.rightMargin
                Layout.leftMargin: Layout.rightMargin
                Layout.topMargin: Layout.rightMargin
                Layout.bottomMargin: Layout.rightMargin
                field.placeholderText: my_side ? qsTr("Amount to sell") : qsTr("Amount to receive")
                field.onTextChanged: capVolume()
            }
        }
    }
}
