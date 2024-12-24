import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qaterial 1.0 as Qaterial
import "../../../Components"
import "../../../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import AtomicDEX.TradingError 1.0
import AtomicDEX.MarketMode 1.0 as Dex

ColumnLayout
{
    id: root
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.fill: parent
    anchors.margins: 20
    spacing: 8

    function focusVolumeField()
    {
        input_volume.forceActiveFocus()
    }

    readonly property string total_amount: API.app.trading_pg.total_amount
    readonly property int input_height: 65
    readonly property int subfield_margin: 5
    property alias swap_btn: swap_btn
    property alias swap_btn_spinner: swap_btn_spinner
    property alias dexErrors: dexErrors


    // Will move to backend: Minimum Fee
    function getMaxBalance()
    {
        if (General.isFilled(base_ticker))
            return API.app.get_balance_info_qstr(base_ticker)
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

    // Market mode selector
    RowLayout
    {
        Layout.topMargin: 2
        Layout.bottomMargin: 2
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        height: 28
        visible: !API.app.trading_pg.maker_mode

        MarketModeSelector
        {
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: 125
            Layout.preferredHeight: 28
            marketMode: Dex.MarketMode.Buy
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }

        Item { Layout.fillWidth: true }

        MarketModeSelector
        {
            marketMode: Dex.MarketMode.Sell
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: 125
            Layout.preferredHeight: 28
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: input_height

        AmountField
        {
            id: input_price

            left_text: qsTr("Price")
            right_text: General.coinWithoutSuffix(right_ticker)
            right_fontsize: 10
            enabled: !(API.app.trading_pg.preferred_order.price !== undefined)
            color: enabled ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
            text: backend_price ? backend_price : General.formatDouble(API.app.trading_pg.cex_price)
            width: parent.width
            height: 36
            radius: 18

            onTextChanged: {
                setPrice(text)
                reset_fees_state()
            }
            Component.onCompleted: text = General.formatDouble(API.app.trading_pg.cex_price) ? General.formatDouble(API.app.trading_pg.cex_price) : 1
        }

        OrderFormSubfield
        {
            id: price_usd_value
            anchors.top: input_price.bottom
            anchors.left: input_price.left
            anchors.topMargin: subfield_margin
            visible: !API.app.trading_pg.invalid_cex_price
            left_btn.onClicked:
            {
                let price = General.formatDouble(parseFloat(input_price.text) - (General.formatDouble(API.app.trading_pg.cex_price)*0.01))
                if (price < 0) price = 0
                setPrice(String(price))
                reset_fees_state()
            }
            right_btn.onClicked:
            {
                let price = General.formatDouble(parseFloat(input_price.text) + (General.formatDouble(API.app.trading_pg.cex_price)*0.01))
                setPrice(String(price))
                reset_fees_state()
            }
            middle_btn.onClicked:
            {
                if (input_price.text == "0") setPrice("1")
                let price = General.formatDouble(API.app.trading_pg.cex_price)
                setPrice(String(price))
                reset_fees_state()
            }
            fiat_value: General.getFiatText(non_null_price, right_ticker)
            left_label: "-1%"
            middle_label: "0%"
            right_label: "+1%"
            left_tooltip_text: qsTr("Reduce 1% relative to CEX market price.")
            middle_tooltip_text: qsTr("Use CEX market price.")
            right_tooltip_text: qsTr("Increase 1% relative to CEX market price.")
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: input_height

        AmountField
        {
            id: input_volume
            width: parent.width
            height: 36
            radius: 18
            left_text: sell_mode ? qsTr("Send") : qsTr("Receive") 
            right_text: General.coinWithoutSuffix(left_ticker)
            right_fontsize: 10
            placeholderText: "0" 
            text: API.app.trading_pg.volume
            onTextChanged: {
                setVolume(text)
                reset_fees_state()
            }
            enabled: !General.privacy_mode
        }

        OrderFormSubfield
        {
            id: volume_usd_value
            anchors.top: input_volume.bottom
            anchors.left: input_volume.left
            anchors.topMargin: subfield_margin
            left_btn.onClicked:
            {
                let volume = General.formatDouble(API.app.trading_pg.max_volume * 0.25)
                setVolume(String(volume))
                reset_fees_state()
            }
            middle_btn.onClicked:
            {
                let volume = General.formatDouble(API.app.trading_pg.max_volume * 0.5)
                setVolume(String(volume))
                reset_fees_state()
            }
            right_btn.onClicked:
            {
                let volume = General.formatDouble(API.app.trading_pg.max_volume)
                setVolume(String(volume))
                reset_fees_state()
            }
            fiat_value: General.getFiatText(non_null_volume, left_ticker)
            left_label: "25%"
            middle_label: "50%"
            right_label:  qsTr("Max")
            left_tooltip_text: General.privacy_mode ? qsTr("Diasble privacy mode to trade") : qsTr("Swap 25% of your tradable balance.")
            middle_tooltip_text: General.privacy_mode ? qsTr("Diasble privacy mode to trade") : qsTr("Swap 50% of your tradable balance.")
            right_tooltip_text: General.privacy_mode ? qsTr("Diasble privacy mode to trade") : qsTr("Swap 100% of your tradable balance.")
        }
    }

    Item
    {
        visible: _useCustomMinTradeAmountCheckbox.checked
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: input_height

        AmountField
        {
            id: input_minvolume
            width: parent.width
            height: 36
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
            anchors.topMargin: subfield_margin
            left_btn.onClicked:
            {
                let volume = input_volume.text * 0.10
                setMinimumAmount(General.formatDouble(volume))
            }
            middle_btn.onClicked:
            {
                let volume = input_volume.text * 0.25
                setMinimumAmount(General.formatDouble(volume))
            }
            right_btn.onClicked:
            {
                let volume = input_volume.text * 0.50
                setMinimumAmount(General.formatDouble(volume))
            }
            fiat_value: General.getFiatText(API.app.trading_pg.min_trade_vol, left_ticker)
            left_label: "10%"
            middle_label: "25%"
            right_label: "50%"
            left_tooltip_text:  qsTr("Minimum accepted trade equals 10% of order volume.")
            middle_tooltip_text:  qsTr("Minimum accepted trade equals 25% of order volume.")
            right_tooltip_text:  qsTr("Minimum accepted trade equals 50% of order volume.")
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 24
        visible: !_useCustomMinTradeAmountCheckbox.checked

        DexLabel
        {
            id: minVolLabel
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 13
            text: qsTr("Min volume: ") + API.app.trading_pg.min_trade_vol
        }
    }

    RowLayout
    {
        Layout.rightMargin: 2
        Layout.leftMargin: 2
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 28
        spacing: 5

        DefaultCheckBox
        {
            id: _useCustomMinTradeAmountCheckbox
            boxWidth: 20
            boxHeight: 20
            labelWidth: 0
            onToggled: setMinimumAmount(0)
        }

        DexLabel
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


    Item { Layout.fillHeight: true }

    // Error messages
    // TODO: Move to toasts
    Item
    {
        height: 55
        Layout.preferredWidth: parent.width

        // Show errors
        Dex.Text
        {
            id: dexErrors
            visible: dexErrors.text_value !== ""
            anchors.fill: parent
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.textSizeSmall4
            color: Dex.CurrentTheme.warningColor
            text_value: General.getTradingError(
                            last_trading_error,
                            curr_fee_info,
                            base_ticker,
                            rel_ticker, left_ticker, right_ticker)
            elide: Text.ElideRight
        }
    }

    Item { Layout.fillHeight: true }

    // Order selected indicator
    Item
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width - 16
        height: 28

        RowLayout
        {
            id: orderSelection
            visible: API.app.trading_pg.preferred_order.price !== undefined
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter

            DexLabel
            {
                Layout.leftMargin: 15
                color: Dex.CurrentTheme.warningColor
                text: qsTr("Order Selected")
            }

            Item { Layout.fillWidth: true }

            Qaterial.FlatButton
            {
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: 30
                Layout.rightMargin: 5
                foregroundColor: Dex.CurrentTheme.warningColor
                onClicked: {
                    API.app.trading_pg.reset_order()
                    reset_fees_state()
                }

                Qaterial.ColorIcon
                {
                    anchors.centerIn: parent
                    iconSize: 16
                    color: Dex.CurrentTheme.warningColor
                    source: Qaterial.Icons.close
                }
            }
        }

        Rectangle
        {
            visible: API.app.trading_pg.preferred_order.price !== undefined
            anchors.fill: parent
            radius: 8
            color: 'transparent'
            border.color: Dex.CurrentTheme.warningColor
        }
    }


    TotalView
    {
        height: 70
        Layout.preferredWidth: parent.width
        Layout.alignment: Qt.AlignHCenter
    }

    DefaultBusyIndicator
    {
        id: swap_btn_spinner
        Layout.alignment: Qt.AlignHCenter
        indicatorSize: 28
        indicatorDotSize: 4
    }
        Item
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width - 16
        height: 28

        DexGradientAppButton
        {
            id: swap_btn
            height: 32
            anchors.fill: parent
            radius: 16
            text: API.app.trading_pg.maker_mode ? qsTr("CREATE MAKER SWAP") : qsTr("START TAKER SWAP")
            font.weight: Font.Medium
            enabled: !General.privacy_mode
        }
    }
}