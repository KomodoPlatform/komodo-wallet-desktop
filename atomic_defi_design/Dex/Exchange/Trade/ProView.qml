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
import "TradeBox/"
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

GridLayout
{
    id: form

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

    function prefWidth(item) { return (width / columns) * item.Layout.columnSpan; }
    function prefHeight(item) { return (height / rows) * item.Layout.rowSpan; }

    anchors.topMargin: 20
    anchors.leftMargin: 10
    anchors.fill: parent

    rows: 12
    columns: 12

    columnSpacing: 20

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

    Connections
    {
        target: app
        function onPairChanged(base, rel) { dex_chart.visible = true }
    }

    // Ticker selectors.
    RowLayout
    {
        id: selectors
        spacing: 20
        Layout.rowSpan: 1
        Layout.columnSpan: 5
        Layout.preferredWidth: prefWidth(this)
        Layout.preferredHeight: prefHeight(this)
        Layout.fillWidth: true
        Layout.fillHeight: true

        TickerSelector
        {
            id: selector_left
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true

            left_side: true
            ticker_list: API.app.trading_pg.market_pairs_mdl.left_selection_box
            ticker: left_ticker
        }

        SwapIcon
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: selector_left.height * 0.65
            Layout.fillWidth: true

            top_arrow_ticker: selector_left.ticker
            bottom_arrow_ticker: selector_right.ticker
            hovered: swap_button.containsMouse

            DefaultMouseArea
            {
                id: swap_button
                anchors.fill: parent
                hoverEnabled: true
                onClicked:
                {
                    if (!block_everything)
                        setPair(true, right_ticker)
                }
            }
        }

        TickerSelector
        {
            id: selector_right
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true

            left_side: false
            ticker_list: API.app.trading_pg.market_pairs_mdl.right_selection_box
            ticker: right_ticker
        }
    }

    DexTradeBox
    {
        visible: false
        enabled: false
        id: dex_chart
        title: qsTr("Chart")
        expandedVert: dex_chart.visible? true : false
        onVisibleChanged: {
            if(visible) {
                expandedVert = true
            }
        }
        canBeFull: true
        onFullScreenChanged: {
            if(fullScreen){
                _best_order_box.visible = false
                _orderbook_box.visible = false
                optionBox.visible = false
                order_form.visible = false
            } else {
                _best_order_box.visible = true
                _orderbook_box.visible = true
                optionBox.visible = true
                order_form.visible = true
            }
        }
        Item {
            id: chart_view
            anchors.fill: parent
            anchors.topMargin: 40
            CandleStickChart {
                id: candleChart
                color: 'transparent'
                anchors.fill: parent
            }

            Component.onCompleted:
            {
                dashboard.webEngineView.parent = chart_view;
                dashboard.webEngineView.anchors.fill = chart_view;
            }
            Component.onDestruction:
            {
                dashboard.webEngineView.visible = false;
                dashboard.webEngineView.stop();
            }
        }
    }

    OrderBook.Vertical
    {
        Layout.columnSpan: 4
        Layout.rowSpan: 5
        Layout.preferredWidth: prefWidth(this)
        Layout.preferredHeight: prefHeight(this)
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    // Place order form.
    Rectangle
    {
        Layout.columnSpan: 3
        Layout.rowSpan: 6
        Layout.preferredWidth: prefWidth(this)
        Layout.preferredHeight: prefHeight(this)
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 10
        color: Dex.CurrentTheme.floatingBackgroundColor

        ColumnLayout
        {
            anchors.fill: parent
            spacing: 10

            DefaultText
            {
                Layout.topMargin: 20
                Layout.leftMargin: 20
                text: qsTr("Place Order")
                font: DexTypo.subtitle3
            }

            // Market mode selector
            RowLayout
            {
                spacing: 10
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                MarketModeSelector
                {
                    Layout.alignment: Qt.AlignHCenter
                    marketMode: MarketMode.Buy
                    ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
                }
                MarketModeSelector
                {
                    Layout.alignment: Qt.AlignHCenter
                    ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
                }
            }

            // Order selected indicator
            Rectangle
            {
                visible: API.app.trading_pg.preffered_order.price !== undefined
                Layout.preferredWidth: parent.width - 20
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                radius: 8
                color: 'transparent'
                border.color: Dex.CurrentTheme.noColor

                DefaultText
                {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 15
                    color: Dex.CurrentTheme.noColor
                    text: qsTr("Order Selected")
                }

                Qaterial.FlatButton
                {
                    foregroundColor: Dex.CurrentTheme.noColor
                    icon.source: Qaterial.Icons.close
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 40
                    width: 40
                    anchors.rightMargin: 15
                    onClicked: API.app.trading_pg.reset_order()
                }
            }

            OrderForm
            {
                id: form_base
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignHCenter
            }

            TotalView
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignHCenter
            }

            FeeInfo
            {
                id: bg
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                visible: false
            }

            DexGradientAppButton
            {
                Layout.preferredHeight: 40
                Layout.preferredWidth: parent.width - 20
                Layout.alignment: Qt.AlignHCenter
                radius: 18

                text: qsTr("START SWAP")
                font.weight: Font.Medium
                enabled: form_base.can_submit_trade
                onClicked: confirm_trade_modal.open()
            }

            ColumnLayout
            {
                spacing: parent.spacing
                visible: errors.text_value !== ""
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width

                HorizontalLine
                {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width
                }

                // Show errors
                DefaultText
                {
                    id: errors
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Style.textSizeSmall4
                    color: Dex.CurrentTheme.noColor
                    text_value: General.getTradingError(
                                    last_trading_error,
                                    curr_fee_info,
                                    base_ticker,
                                    rel_ticker, left_ticker, right_ticker)
                }
            }
        }
    }

    Column
    {
        Layout.topMargin: 20
        Layout.rowSpan: 5
        Layout.columnSpan: 5
        Layout.preferredWidth: prefWidth(this)
        Layout.preferredHeight: prefHeight(this)
        Layout.fillHeight: true
        Layout.fillWidth: true
        DefaultText { font: DexTypo.subtitle3; text: qsTr("Trading Information") }
        Qaterial.LatoTabBar
        {
            id: tabView
            property int taux_exchange: 0
            property int order_idx: 1
            property int history_idx: 2

            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            Material.foreground: Dex.CurrentTheme.foregroundColor
            background: null
            topPadding: 15
            leftPadding: 5

            Qaterial.LatoTabButton
            {
                width: 150
                text: qsTr("Exchange Rates")
                font.pixelSize: 14
                textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
                textSecondaryColor: Dex.CurrentTheme.foregroundColor2
                opacity: checked ? 1 : .6
            }
            Qaterial.LatoTabButton
            {
                width: 120
                text: qsTr("Orders")
                font.pixelSize: 14
                textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
                textSecondaryColor: Dex.CurrentTheme.foregroundColor2
                opacity: checked ? 1 : .6
            }
            Qaterial.LatoTabButton
            {
                width: 120
                text: qsTr("History")
                font.pixelSize: 14
                textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
                textSecondaryColor: Dex.CurrentTheme.foregroundColor2
                opacity: checked ? 1 : .6
            }
        }
        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 436
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

    BestOrder.List
    {
        Layout.rowSpan: 5
        Layout.columnSpan: 4
        Layout.fillHeight: true
        Layout.fillWidth: true
        id: best_order_list
    }

    ModalLoader
    {
        id: confirm_trade_modal
        sourceComponent: ConfirmTradeModal {}
    }
}
