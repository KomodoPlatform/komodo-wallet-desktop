import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0
import "../../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

ColumnLayout
{
    id: root

    function focusVolumeField()
    {
        input_volume.forceActiveFocus()
    }

    readonly property string total_amount: API.app.trading_pg.total_amount

    readonly property bool can_submit_trade: last_trading_error === TradingError.None

    // Will move to backend: Minimum Fee
    function getMaxBalance()
    {
        if (General.isFilled(base_ticker))
            return API.app.get_balance(base_ticker)

        return "0"
    }

    // Will move to backend: Minimum Fee
    function getMaxVolume()
    {
        // base in this orderbook is always the left side, so when it's buy, we want the right side balance (rel in the backend)
        const value = sell_mode ? API.app.trading_pg.orderbook.base_max_taker_vol.decimal :
            API.app.trading_pg.orderbook.rel_max_taker_vol.decimal

        if (General.isFilled(value))
            return value

        return getMaxBalance()
    }

    function setMinimumAmount(value) { API.app.trading_pg.min_trade_vol = value }

    Connections
    {
        target: exchange_trade
        function onBackend_priceChanged() { input_price.text = exchange_trade.backend_price; }
        function onBackend_volumeChanged() { input_volume.text = exchange_trade.backend_volume; }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: input_price.height + price_usd_value.height + price_usd_value.anchors.topMargin

        AmountField
        {
            id: input_price

            left_text: qsTr("Price")
            right_text: right_ticker
            enabled: !(API.app.trading_pg.preffered_order.price !== undefined)
            color: enabled ? Dex.CurrentTheme.foregroundColor1 : Dex.CurrentTheme.foregroundColor2
            text: backend_price
            width: parent.width
            height: 41
            radius: 18

            onTextChanged: setPrice(text)
        }

        OrderFormSubfield
        {
            id: price_usd_value
            anchors.top: input_price.bottom
            anchors.left: input_price.left
            anchors.topMargin: 7
            visible: !API.app.trading_pg.invalid_cex_price
            left_btn.onClicked:
            {
                let price = General.formatDouble(parseFloat(input_price.text) - (General.formatDouble(API.app.trading_pg.cex_price)*0.01))
                if (price < 0) price = 0
                setPrice(String(price))
            }
            right_btn.onClicked:
            {
                let price = General.formatDouble(parseFloat(input_price.text) + (General.formatDouble(API.app.trading_pg.cex_price)*0.01))
                setPrice(String(price))
            }
            middle_btn.onClicked:
            {
                if (input_price.text == "0") setPrice("1")
                let price = General.formatDouble(API.app.trading_pg.cex_price)
                setPrice(String(price))
            }
            fiat_value: General.getFiatText(non_null_price, right_ticker)
            left_label: "-1%"
            middle_label: "0%"
            right_label: "+1%"
            left_tooltip_text: "Reduce 1% relative to CEX market price."
            middle_tooltip_text: "Use CEX market price."
            right_tooltip_text: "Increase 1% relative to CEX market price."
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.topMargin: 8
        Layout.preferredHeight: input_volume.height + volume_usd_value.height + volume_usd_value.anchors.topMargin

        AmountField
        {
            id: input_volume
            width: parent.width
            height: 41
            radius: 18
            left_text: qsTr("Volume")
            right_text: left_ticker
            placeholderText: sell_mode ? qsTr("Amount to sell") : qsTr("Amount to receive")
            text: API.app.trading_pg.volume
            onTextChanged: setVolume(text)
        }

        OrderFormSubfield
        {
            id: volume_usd_value
            anchors.top: input_volume.bottom
            anchors.left: input_volume.left
            anchors.topMargin: 7
            left_btn.onClicked:
            {
                let volume = General.formatDouble(API.app.trading_pg.max_volume * 0.25)
                setVolume(String(volume))
            }
            middle_btn.onClicked:
            {
                let volume = General.formatDouble(API.app.trading_pg.max_volume * 0.5)
                setVolume(String(volume))
            }
            right_btn.onClicked:
            {
                let volume = General.formatDouble(API.app.trading_pg.max_volume)
                setVolume(String(volume))
            }
            fiat_value: General.getFiatText(non_null_volume, left_ticker)
            left_label: "25%"
            middle_label: "50%"
            right_label: "Max"
            left_tooltip_text: "Swap 25% of your balance."
            middle_tooltip_text: "Swap 50% of your balance."
            right_tooltip_text: "Swap maximum balance."
        }
    }

    Item
    {
        visible: _useCustomMinTradeAmountCheckbox.checked
        Layout.preferredWidth: parent.width
        Layout.topMargin: 8
        Layout.preferredHeight: input_minvolume.height + volume_usd_value.height + volume_usd_value.anchors.topMargin

        AmountField
        {
            id: input_minvolume
            width: parent.width
            height: 41
            radius: 18
            left_text: qsTr("Min Volume")
            right_text: left_ticker
            placeholderText: sell_mode ? qsTr("Min amount to sell") : qsTr("Min amount to receive")
            text: API.app.trading_pg.min_trade_vol
            onTextChanged: if (API.app.trading_pg.min_trade_vol != text) setMinimumAmount(text)
        }

        OrderFormSubfield
        {
            id: minvolume_usd_value
            anchors.top: input_minvolume.bottom
            anchors.left: input_minvolume.left
            anchors.topMargin: 7
            left_btn.onClicked:
            {
                let volume = API.app.trading_pg.max_volume * 0.05
                if (volume > parseFloat(input_volume.text))
                    volume = parseFloat(input_volume.text)
                setMinimumAmount(General.formatDouble(volume))
            }
            middle_btn.onClicked:
            {
                let volume = API.app.trading_pg.max_volume * 0.10
                if (volume > parseFloat(input_volume.text))
                    volume = parseFloat(input_volume.text)
                setMinimumAmount(General.formatDouble(volume))
            }
            right_btn.onClicked:
            {
                let volume = API.app.trading_pg.max_volume * 0.20
                if (volume > parseFloat(input_volume.text))
                    volume = parseFloat(input_volume.text)
                setMinimumAmount(General.formatDouble(volume))
            }
            fiat_value: General.getFiatText(non_null_volume, left_ticker)
            left_label: "5%"
            middle_label: "10%"
            right_label: "20%"
            left_tooltip_text: "Minimum accepted trade equals 5% of your balance."
            middle_tooltip_text: "Minimum accepted trade equals 10% of your balance."
            right_tooltip_text: "Minimum accepted trade equals 20% of your balance."
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: minVolLabel.height
        Layout.topMargin: 8
        visible: !_useCustomMinTradeAmountCheckbox.checked

        DefaultText
        {
            id: minVolLabel
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 13
            text: qsTr("Min volume: ") + API.app.trading_pg.min_trade_vol
        }

        DefaultText
        {
            anchors.left: minVolLabel.right
            anchors.leftMargin: 8
            anchors.verticalCenter: minVolLabel.verticalCenter

            text: General.cex_icon
            color: Dex.CurrentTheme.foregroundColor3

            DefaultMouseArea
            {
                anchors.fill: parent
                onClicked: _sliderHelpModal.open()
            }

            ModalLoader
            {
                id: _sliderHelpModal
                sourceComponent: HelpModal
                {
                    title: qsTr("How to use the pro-view slider ?")
                    helpSentence: qsTr("This slider is used to setup the order requirements you need.\nLeft slider: Sets the minimum amount required to process a trade.\nRight slider: Sets the volume you want to trade.")
                }
            }
        }
    }

    RowLayout
    {
        Layout.topMargin: 10
        Layout.rightMargin: 2
        Layout.leftMargin: 2
        Layout.fillWidth: true
        spacing: 5

        DefaultCheckBox
        {
            id: _useCustomMinTradeAmountCheckbox
            boxWidth: 20
            boxHeight: 20
            labelWidth: 0
        }

        DefaultText
        {
            Layout.fillWidth: true
            height: _useCustomMinTradeAmountCheckbox.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Label.WordWrap
            text: qsTr("Use custom minimum trade amount")
            color: Dex.CurrentTheme.foregroundColor3
            font.pixelSize: 13
        }
    }

    DefaultRangeSlider
    {
        id: _volumeRange
        visible: false

        function getRealValue() { return first.position * (first.to - first.from); }
        function getRealValue2() { return second.position * (second.to - second.from); }

        enabled: input_volume.enabled && !(!sell_mode && General.isZero(non_null_price)) && to > 0

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width

        from: API.app.trading_pg.orderbook.current_min_taker_vol
        to: Math.max(0, parseFloat(max_volume))

        first.value: parseFloat(API.app.trading_pg.min_trade_vol)

        firstDisabled: !_useCustomMinTradeAmountCheckbox.checked

        second.value: parseFloat(non_null_volume)

        first.onValueChanged: if (first.pressed) setMinimumAmount(General.formatDouble(first.value))
        second.onValueChanged: if (second.pressed) setVolume(General.formatDouble(second.value))
    }
}