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

RowLayout
{
    id: form

    spacing: 16

    function selectOrder(is_asks, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume, base_min_volume, base_max_volume, rel_min_volume, rel_max_volume, base_max_volume_denom, base_max_volume_numer, uuid)
    {
        setMarketMode(!is_asks ? MarketMode.Sell : MarketMode.Buy)

        API.app.trading_pg.preffered_order = {
            "coin": coin,
            "price": price,
            "quantity": quantity,
            "price_denom": price_denom,
            "price_numer": price_numer,
            "quantity_denom": quantity_denom,
            "quantity_numer": quantity_numer,
            "min_volume": min_volume,
            "base_min_volume": base_min_volume,
            "base_max_volume": base_max_volume,
            "rel_min_volume": rel_min_volume,
            "rel_max_volume": rel_max_volume,
            "base_max_volume_denom": base_max_volume_denom,
            "base_max_volume_numer": base_max_volume_numer,
            "uuid": uuid
        }
        form_base.focusVolumeField()
    }

    Connections
    {
        target: exchange_trade
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
                tabView.currentIndex = 1
            }
        }
    }

    ColumnLayout
    {
        Layout.minimumWidth: 480
        Layout.maximumWidth: 735
        Layout.fillWidth: true

        Layout.fillHeight: true

        spacing: 20

        // Chart
        ColumnLayout
        {
            Layout.fillWidth: true

            Layout.minimumHeight: 190
            Layout.maximumHeight: 360
            Layout.fillHeight: true

            spacing: 10

            DefaultText { font: DexTypo.subtitle1; text: qsTr("Chart") }

            Chart
            {
                id: chartView

                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        // Ticker selectors.
        TickerSelectors
        {
            id: selectors

            Layout.fillWidth: true
            Layout.preferredHeight: 70
        }

        // Trading Informations
        ColumnLayout
        {
            Layout.fillWidth: true

            Layout.minimumHeight: 380
            Layout.maximumHeight: 500
            Layout.fillHeight: true

            spacing: 10

            DefaultText { font: DexTypo.subtitle1; text: qsTr("Trading Information") }

            Qaterial.LatoTabBar
            {
                id: tabView
                property int taux_exchange: 0
                property int order_idx: 1
                property int history_idx: 2

                Material.foreground: Dex.CurrentTheme.foregroundColor
                background: null
                Layout.leftMargin: 6

                Qaterial.LatoTabButton
                {
                    text: qsTr("Exchange Rates")
                    font.pixelSize: 14
                    textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
                    indicatorColor: Dex.CurrentTheme.foregroundColor
                    textSecondaryColor: Dex.CurrentTheme.foregroundColor2
                }
                Qaterial.LatoTabButton
                {
                    text: qsTr("Orders")
                    font.pixelSize: 14
                    textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
                    textSecondaryColor: Dex.CurrentTheme.foregroundColor2
                    indicatorColor: Dex.CurrentTheme.foregroundColor
                }
                Qaterial.LatoTabButton
                {
                    text: qsTr("History")
                    font.pixelSize: 14
                    textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
                    textSecondaryColor: Dex.CurrentTheme.foregroundColor2
                    indicatorColor: Dex.CurrentTheme.foregroundColor
                }
            }

            Rectangle
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Dex.CurrentTheme.floatingBackgroundColor
                radius: 10

                Qaterial.SwipeView
                {
                    id: swipeView
                    clip: true
                    interactive: false
                    currentIndex: tabView.currentIndex
                    anchors.fill: parent
                    onCurrentIndexChanged:
                    {
                        swipeView.currentItem.update();
                        if (currentIndex === 2) history_component.list_model_proxy.is_history = true;
                        else history_component.list_model_proxy.is_history = false;
                    }

                    PriceLine { id: price_line_obj }

                    OrdersView.OrdersPage { id: order_component; clip: true }
                    OrdersView.OrdersPage
                    {
                        id: history_component
                        is_history: true
                        clip: true
                    }
                }
            }
        }
    }

    ColumnLayout
    {
        Layout.minimumWidth: 353
        Layout.fillWidth: true

        OrderBook.Vertical
        {
            Layout.fillWidth: true

            Layout.minimumHeight: 365
            Layout.maximumHeight: 536
            Layout.fillHeight: true
        }

        // Best Orders
        BestOrder.List
        {
            Layout.fillWidth: true

            Layout.minimumHeight: 196
            Layout.fillHeight: true
        }
    }

    // Place order form.
    PlaceOrderForm.Main
    {
        Layout.minimumWidth: 302
        Layout.maximumWidth: 350
        Layout.fillWidth: true

        Layout.minimumHeight: 571
        Layout.fillHeight: true
    }

    ModalLoader
    {
        id: confirm_trade_modal
        sourceComponent: ConfirmTradeModal {}
    }
}
