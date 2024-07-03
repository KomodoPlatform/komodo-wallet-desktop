import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

import Qaterial 1.0 as Qaterial

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0

import "../../Components"
import "../../Constants"
import "../../Wallet"

import App 1.0

// Trade Form / Component import
import "Trading/"
import "Trading/Items/"

// OrderBook / Component import
import "OrderBook/" as OrderBook

// Best Order
import "BestOrder/" as BestOrder

// Orders (orders, history)
import "Orders/" as OrdersView

import "../../Screens"
import Dex.Themes 1.0 as Dex

import "../ProView"
import "../ProView/PlaceOrderForm" as PlaceOrderForm
import "../ProView/TradingInfo" as TradingInfo

RowLayout
{
    id: form

    property alias trInfo: tradingInfo
    property alias marketsOrderBook: marketsOrderBook
    property alias placeOrderForm: placeOrderForm

    function selectOrder(
        is_asks, coin, price, price_denom, 
        price_numer, min_volume, base_min_volume, base_max_volume, 
        rel_min_volume, rel_max_volume, base_max_volume_denom, 
        base_max_volume_numer, uuid)
    {
        setMarketMode(!is_asks ? MarketMode.Sell : MarketMode.Buy)

        let selected_order = {
            "coin": coin,
            "price": price,
            "price_denom": price_denom,
            "price_numer": price_numer,
            "min_volume": min_volume,
            "base_min_volume": base_min_volume,
            "base_max_volume": base_max_volume,
            "rel_min_volume": rel_min_volume,
            "rel_max_volume": rel_max_volume,
            "base_max_volume_denom": base_max_volume_denom,
            "base_max_volume_numer": base_max_volume_numer,
            "uuid": uuid
        }

        API.app.trading_pg.preferred_order = selected_order

        // Shows place order form in case it has been hidden in the settings.
        placeOrderForm.visible = true
    }

    Connections
    {
        target: exchange_trade
        enabled: form.enabled
        function onBuy_sell_rpc_busyChanged()
        {
            if (buy_sell_rpc_busy)
                return

            const response = General.clone(buy_sell_last_rpc_data)
            if (response.error_code)
            {
                confirm_trade_modal.close()

                toast.show(qsTr("Failed to place the order"),
                           General.time_toast_important_error,
                           response.error_message)

                return
            }
            else if (response.result && response.result.uuid)
            {
                // Make sure there is information
                confirm_trade_modal.close()

                toast.show(qsTr("Placed the order"), General.time_toast_basic_info,
                           General.prettifyJSON(response.result), false)

                General.prevent_coin_disabling.restart()
                // Show the orders tab unless settings say otherwise
                if (API.app.settings_pg.postorder_enabled)
                {
                    tradingInfo.currentIndex = 1
                }
            }
        }
    }

    // Trading Informations
    TradingInfo.Main
    {
        id: tradingInfo
        Layout.alignment: Qt.AlignTop
        Layout.minimumWidth: tradingInfo.visible ? 450 : -1
        Layout.maximumWidth: (!marketsOrderBook.visible) || (!placeOrderForm.visible) ? -1 : 450
        Layout.fillHeight: true
    }

    // Best Orders & Order Book
    Market
    {
        id: marketsOrderBook
        Layout.maximumWidth: 350
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        spacing: 4
    }

    // Place order form.
    PlaceOrderForm.Main
    {
        id: placeOrderForm

        Layout.minimumWidth: visible ? 305 : -1
        Layout.maximumWidth: 305
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    ModalLoader
    {
        id: confirm_trade_modal
        sourceComponent: ConfirmTradeModal { }
    }
}
