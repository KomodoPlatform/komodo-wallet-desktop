import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    id: root

    property alias field: input_volume.field
    property bool my_side: false
    property bool enabled: true

    function canShowFees() {
        return my_side && getVolume() !== "0"
    }

    function getTickerList() {
        return my_side ? General.getTickersAndBalances(getFilteredCoins()) : General.getTickers(getFilteredCoins())
    }

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

    function getMaxVolume() {
        return API.get().get_balance(getTicker())
    }

    function getMaxTradableVolume(set_as_current) {
        // set_as_current should be true if input_volume is updated
        // if it's called for cap check, it should be false because that's not the current input_volume
        return getSendAmountAfterFees(getMaxVolume(), set_as_current)
    }

    function setMax() {
        input_volume.field.text = getMaxTradableVolume(true)
    }

    function reset() {
        if(my_side) {
            setMax()
        }
        else {
            input_volume.field.text = ''
        }
    }

    function capVolume() {
        if(inCurrentPage() && my_side && input_volume.field.acceptableInput) {
            const amt = parseFloat(input_volume.field.text)
            const cap_with_fees = getMaxTradableVolume(false)
            if(amt > cap_with_fees) {
                input_volume.field.text = cap_with_fees.toString()
                updateTradeInfo()
            }
        }

        if(my_side) {
            // Rel is dependant on Base if price is set so update that
            updateRelAmount()

            // Update the new fees, input_volume might be changed
            updateTradeInfo()
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

                enabled: root.enabled

                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.rightMargin: 15

                model: getTickerList()
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
                onClicked: setMax()
            }

            AmountField {
                id: input_volume
                field.enabled: root.enabled

                Layout.fillWidth: true
                Layout.rightMargin: combo.Layout.rightMargin
                Layout.leftMargin: Layout.rightMargin
                Layout.topMargin: Layout.rightMargin
                Layout.bottomMargin: Layout.rightMargin
                field.placeholderText: my_side ? qsTr("Amount to sell") :
                                                 field.enabled ? qsTr("Amount to receive") : qsTr("Please fill the send amount")
                field.onTextChanged: capVolume()
            }
        }

        RowLayout {
            Layout.leftMargin: combo.Layout.rightMargin
            Layout.bottomMargin: Layout.leftMargin

            ColumnLayout {
                Layout.alignment: Qt.AlignLeft

                DefaultText {
                    id: tx_fee_text
                    text: canShowFees() ? qsTr('Transaction Fee:') : ''
                    font.pointSize: Style.textSizeSmall
                }

                DefaultText {
                    text: canShowFees() ? qsTr('Trading Fee:') : ''
                    font.pointSize: tx_fee_text.font.pointSize
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignRight

                DefaultText {
                    text: canShowFees() ? curr_trade_info.tx_fee + ' ' + (curr_trade_info.is_ticker_of_fees_eth ? "ETH" : getTicker(true)) : ''
                    font.pointSize: tx_fee_text.font.pointSize
                }

                DefaultText {
                    text: canShowFees() ? curr_trade_info.trade_fee + ' ' + getTicker(true) : ''
                    font.pointSize: tx_fee_text.font.pointSize
                }
            }
        }
    }
}
