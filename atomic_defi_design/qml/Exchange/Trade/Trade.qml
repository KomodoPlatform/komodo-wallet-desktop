import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import QtGraphicalEffects 1.0

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0

import "../../Components"
import "../../Constants"
import "../../Wallet"

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

import "./" as Here

Item {
    id: exchange_trade
    readonly property string total_amount: API.app.trading_pg.total_amount
    //property var form_base: sell_mode? form_base.formBase : buyBox.formBase
    Component.onCompleted: {
        API.app.trading_pg.on_gui_enter_dex()
        onOpened()
    }

    Component.onDestruction: {
        API.app.trading_pg.on_gui_leave_dex()
    }
    property bool isUltraLarge: width > 1400
    onIsUltraLargeChanged: {
        if (isUltraLarge) {
            API.app.trading_pg.orderbook.asks.proxy_mdl.qml_sort(
                        0, Qt.DescendingOrder)
        } else {
            API.app.trading_pg.orderbook.asks.proxy_mdl.qml_sort(
                        0, Qt.AscendingOrder)
        }
    }

    readonly property bool block_everything: swap_cooldown.running
                                             || fetching_multi_ticker_fees_busy

    readonly property bool fetching_multi_ticker_fees_busy: false

    signal prepareMultiOrder
    property bool multi_order_values_are_valid: true

    readonly property string non_null_price: backend_price === '' ? '0' : backend_price
    readonly property string non_null_volume: backend_volume === '' ? '0' : backend_volume
    readonly property bool price_is_empty: parseFloat(non_null_price) <= 0

    readonly property string backend_price: API.app.trading_pg.price
    function setPrice(v) {
        API.app.trading_pg.price = v
    }
    readonly property int last_trading_error: API.app.trading_pg.last_trading_error
    readonly property string max_volume: API.app.trading_pg.max_volume
    readonly property string backend_volume: API.app.trading_pg.volume
    function setVolume(v) {
        API.app.trading_pg.volume = v
    }

    property bool sell_mode: API.app.trading_pg.market_mode.toString(
                                 ) === "Sell"
    function setMarketMode(v) {
        API.app.trading_pg.market_mode = v
    }

    readonly property string base_amount: API.app.trading_pg.base_amount
    readonly property string rel_amount: API.app.trading_pg.rel_amount

    Timer {
        id: swap_cooldown
        repeat: false
        interval: 1000
    }

    property var onOrderSuccess: function (){
    General.prevent_coin_disabling.restart()
    tabView.currentIndex = 1
    multi_order_switch.checked = API.app.trading_pg.multi_order_enabled
}

    onSell_modeChanged: {
        reset()
    }

    function inCurrentPage() {
        return exchange.inCurrentPage()
                && exchange.current_page === idx_exchange_trade
    }

    function reset() {
        //API.app.trading_pg.multi_order_enabled = false
        //multi_order_switch.checked = API.app.trading_pg.multi_order_enabled
    }

    readonly property var preffered_order: API.app.trading_pg.preffered_order

    function selectOrder(is_asks, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer) {
        setMarketMode(!is_asks ? MarketMode.Sell : MarketMode.Buy)

        API.app.trading_pg.preffered_order = {
            "coin": coin,
            "price": price,
            "quantity": quantity,
            "price_denom": price_denom,
            "price_numer": price_numer,
            "quantity_denom": quantity_denom,
            "quantity_numer": quantity_numer
        }

        form_base.focusVolumeField()
    }

    // Cache Trade Info
    property bool valid_fee_info: API.app.trading_pg.fees.base_transaction_fees !== undefined
    readonly property var curr_fee_info: API.app.trading_pg.fees
    property var fees_data: []

    // Trade
    function onOpened(ticker) {
        if (!General.initialized_orderbook_pair) {
            General.initialized_orderbook_pair = true
            API.app.trading_pg.set_current_orderbook(General.default_base,
                                                     General.default_rel)
        }

        reset()
        setPair(true, ticker)
        app.pairChanged(base_ticker, rel_ticker)
    }

    function setPair(is_left_side, changed_ticker) {
        swap_cooldown.restart()

        if (API.app.trading_pg.set_pair(is_left_side, changed_ticker))
            pairChanged(base_ticker, rel_ticker)
    }

    function trade(options, default_config) {
        // Will move to backend - nota, conf
        let nota = ""
        let confs = ""

        if (options.enable_custom_config) {
            if (options.is_dpow_configurable) {
                nota = options.enable_dpow_confs ? "1" : "0"
            }

            if (nota !== "1") {
                confs = options.required_confirmation_count.toString()
            }
        } else {
            if (General.exists(default_config.requires_notarization)) {
                nota = default_config.requires_notarization ? "1" : "0"
            }

            if (nota !== "1" && General.exists(
                        default_config.required_confirmations)) {
                confs = default_config.required_confirmations.toString()
            }
        }

        if (sell_mode)
            API.app.trading_pg.place_sell_order(nota, confs)
        else
            API.app.trading_pg.place_buy_order(nota, confs)
    }

    readonly property bool buy_sell_rpc_busy: API.app.trading_pg.buy_sell_rpc_busy
    readonly property var buy_sell_last_rpc_data: API.app.trading_pg.buy_sell_last_rpc_data

    onBuy_sell_rpc_busyChanged: {
        if (buy_sell_rpc_busy)
            return

        const response = General.clone(buy_sell_last_rpc_data)

        if (response.error_code) {
            confirm_trade_modal.close()

            toast.show(qsTr("Failed to place the order"),
                       General.time_toast_important_error,
                       response.error_message)

            return
        } else if (response.result && response.result.uuid) {
            // Make sure there is information
            confirm_trade_modal.close()

            toast.show(qsTr("Placed the order"), General.time_toast_basic_info,
                       General.prettifyJSON(response.result), false)

            General.prevent_coin_disabling.restart()
            tabView.currentIndex = 1
        }
    }

    // Form
    ColumnLayout {
        id: form

        spacing: 10
        anchors.topMargin: 40
        anchors.leftMargin: 10
        anchors.fill: parent
        SplitView {
            id: splitView
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 15
            handle: Item {
                implicitWidth: 10
                implicitHeight: 10
                InnerBackground {
                    implicitWidth: 6
                    implicitHeight: 16
                    anchors.centerIn: parent
                    opacity: .2
                }
            }

            ItemBox {
                id: left_section
                minimumWidth: 650
                defaultWidth: 650
                expandedHort: true
                SplitView.fillHeight: true
                title: "Chart View"
                color: 'transparent'
                border.color: 'transparent'
                SplitView {
                    anchors.fill: parent
                    anchors.margins: 00
                    anchors.topMargin: 0
                    anchors.rightMargin: 0
                    orientation: Qt.Vertical
                    handle: Item {
                        implicitWidth: 10
                        implicitHeight: 10
                        InnerBackground {
                            implicitWidth: 16
                            implicitHeight: 6
                            anchors.centerIn: parent
                            opacity: .4
                        }
                    }
                    ItemBox {
                        title: "Chart View"
                        expandedVert: true
                        Item {
                            id: chart_view
                            anchors.fill: parent
                            anchors.topMargin: 40
                            CandleStickChart {
                                anchors.fill: parent
                            }
                        }
                    }

                    RowLayout {
                        id: selectors
                        spacing: 20
                        SplitView.maximumHeight: 80
                        SplitView.minimumHeight: 75

                        TickerSelector {
                            id: selector_left
                            left_side: true
                            Layout.fillHeight: true
                            ticker_list: API.app.trading_pg.market_pairs_mdl.left_selection_box
                            ticker: left_ticker
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.fillWidth: true
                        }

                        SwapIcon {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.preferredHeight: selector_left.height * 0.65

                            top_arrow_ticker: selector_left.ticker
                            bottom_arrow_ticker: selector_right.ticker
                            hovered: swap_button.containsMouse

                            DefaultMouseArea {
                                id: swap_button
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (!block_everything)
                                        setPair(true, right_ticker)
                                }
                            }
                        }

                        TickerSelector {
                            id: selector_right
                            left_side: false
                            ticker_list: API.app.trading_pg.market_pairs_mdl.right_selection_box
                            ticker: right_ticker
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            Layout.fillWidth: true
                        }
                    }
                    ItemBox {
                        title: "Multi-Order"
                        defaultHeight: 250
                        visible: false
//                        MultiOrder {
//                            anchors.topMargin: 40
//                            anchors.fill: parent
//                        }
                    }

                    ItemBox {
                        title: "OrderBook"
                        defaultHeight: 300
                        Behavior on defaultHeight {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        visible: !isUltraLarge

                        OrderBook.Horizontal {
                            anchors.topMargin: 40
                            anchors.fill: parent
                            clip: !parent.contentVisible
                            visible: parent.visible
                        }
                    }
                    ItemBox {
                        id: optionBox
                        defaultHeight: tabView.currentIndex === 0 ? 200 : 400
                        Connections {
                            target: tabView
                            function onCurrentIndexChanged() {
                                if (tabView.currentIndex !== 0) {
                                    optionBox.setHeight(400)
                                } else {
                                    optionBox.setHeight(200)
                                }
                            }
                        }

                        title: "Options"
                        Column {
                            topPadding: 40
                            width: parent.width
                            height: parent.height
                            clip: !parent.contentVisible
                            anchors.horizontalCenter: parent.horizontalCenter
                            Qaterial.TabBar {
                                z: 4
                                id: tabView
                                property int taux_exchange: 0
                                property int order_idx: 1
                                property int history_idx: 2
                                width: parent.width
                                currentIndex: tabView.currentIndex
                                anchors.horizontalCenter: parent.horizontalCenter
                                Material.foreground: theme.foregroundColor
                                background: Rectangle {
                                    radius: 0
                                    color: theme.dexBoxBackgroundColor
                                }
                                onCurrentIndexChanged: {
                                    swipeView.pop()
                                    switch (currentIndex) {
                                    case 0:
                                        swipeView.push(priceLine)
                                        break
                                    case 1:
                                        swipeView.push(order_component)
                                        break
                                    case 2:
                                        swipeView.push(history_component)
                                        break
                                    default:
                                        priceLine
                                    }
                                }

                                y: 5
                                leftPadding: 15
                                Qaterial.TabButton {
                                    width: 150
                                    text: qsTr("Exchange Rates")
                                    foregroundColor: CheckBox ? Qaterial.Style.buttonAccentColor : theme.foregroundColor
                                    opacity: checked ? 1 : .6
                                }
                                Qaterial.TabButton {
                                    width: 120
                                    text: qsTr("Orders")
                                    foregroundColor: CheckBox ? Qaterial.Style.buttonAccentColor : theme.foregroundColor
                                    opacity: checked ? 1 : .6
                                }
                                Qaterial.TabButton {
                                    width: 120
                                    text: qsTr("history")
                                    foregroundColor: CheckBox ? Qaterial.Style.buttonAccentColor : theme.foregroundColor
                                    opacity: checked ? 1 : .6
                                }
                            }
                            Item {
                                anchors.horizontalCenter: parent.horizontalCenter
                                //radius: 4
                                width: parent.width
                                height: parent.height - (tabView.height + 40)
                                //verticalShadow: false
                                StackView {
                                    id: swipeView

                                    initialItem: priceLine
                                    anchors.fill: parent

                                    LoaderBusyIndicator {
                                        visible: swipeView.busy
                                    }
                                    Component {
                                        id: priceLine
                                        PriceLine {
                                            id: price_line_obj
                                        }
                                    }
                                    Component {
                                        id: order_component
                                        OrdersView.OrdersPage {
                                            clip: true
                                        }
                                    }
                                    Component {
                                        id: history_component
                                        OrdersView.OrdersPage {
                                            is_history: true
                                            clip: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ItemBox {
                minimumWidth: 350
                maximumWidth: 380
                defaultWidth: 350
                title: "OrderBook & Best Orders"
                color: 'transparent'
                closable: false
                visible: isUltraLarge
                DefaultSplitView {
                    anchors.topMargin: 40
                    anchors.fill: parent
                    orientation: Qt.Vertical
                    visible: parent.contentVisible
                    handle: Item {
                        implicitWidth: 10
                        implicitHeight: 10
                        InnerBackground {
                            implicitWidth: 16
                            implicitHeight: 6
                            anchors.centerIn: parent
                            opacity: .4
                        }
                    }
                    Item {
                        SplitView.minimumHeight: 1
                        SplitView.maximumHeight: 1
                        SplitView.fillWidth: true
                    }
                    ItemBox {
                        SplitView.fillWidth: true
                        //clip: true
                        title: "OrderBook"
                        expandedVert: true

                        Behavior on SplitView.preferredWidth {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                        OrderBook.Vertical {
                            clip: !parent.contentVisible
                            visible: parent.contentVisible
                            anchors.topMargin: 40
                            anchors.fill: parent
                        }
                    }
                    ItemBox {
                        id: _best_order_box
                        SplitView.fillWidth: true
                        SplitView.fillHeight: true
                        defaultHeight: 250
                        minimumHeight: 130
                        //clip: true
                        //smooth: true
                        title: "Best Orders"
                        reloadable: true
                        onReload: {
                            API.app.trading_pg.orderbook.refresh_best_orders()
                        }

                        Behavior on SplitView.preferredWidth {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                        BestOrder.List {
                            clip: !parent.contentVisible
                            id: best_order_list
                            visible: parent.contentVisible
                            y: 40
                            width: parent.width
                            height: parent.height-40
                        }
                    }
                }
            }

            ItemBox {
                defaultWidth: 300
                maximumWidth: 300
                minimumWidth: 280
                SplitView.fillHeight: true
                title: "Buy & Sell"
                color: 'transparent'
                border.color: 'transparent'
                //clip: true
                SplitView {
                    visible: parent.contentVisible
                    orientation: Qt.Vertical
                    anchors.fill: parent
                    anchors.topMargin: 45
                    handle: Item {
                        implicitWidth: 10
                        implicitHeight: 10
                        InnerBackground {
                            implicitWidth: 16
                            implicitHeight: 6
                            anchors.centerIn: parent
                            opacity: .4
                        }
                    }
                    ItemBox {
                        title: "Total"
                        defaultHeight: 90
                        hideHeader: true
                        //clip: true
                        visible: true
                        bottomBorderColor: sell_mode? theme.greenColor : theme.redColor
                        TotalView {}
                    }
                    Item {
                        SplitView.fillWidth: true
                        SplitView.preferredHeight: 30
                        SplitView.maximumHeight: 35
                        Row {
                            width: parent.width - 100
                            anchors.centerIn: parent
                            Rectangle {
                                width: (parent.width / 2)
                                height: 30
                                radius: 8
                                color: !sell_mode ? Qt.darker(
                                                        theme.greenColor) : theme.backgroundColor
                                border.color: !sell_mode ? theme.greenColor : theme.dexBoxBackgroundColor
                                Rectangle {
                                    anchors.right: parent.right
                                    color: parent.color
                                    height: parent.height
                                    width: parent.radius
                                    border.color: parent.border.color
                                    border.width: parent.border.width

                                    Rectangle {
                                        anchors.left: parent.left
                                        color: parent.color
                                        height: parent.height - (parent.border.width * 2)
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 2
                                    }
                                }
                                DefaultText {
                                    anchors.centerIn: parent
                                    opacity: !sell_mode ? 1 : .5
                                    text: "Buy "+left_ticker
                                    color: !sell_mode? Qaterial.Colors.white : theme.foregroundColor
                                }
                                DefaultMouseArea {
                                    anchors.fill: parent
                                    id: buySelector
                                    onClicked: setMarketMode(MarketMode.Buy)
                                }
                            }
                            Rectangle {
                                width: (parent.width / 2)
                                height: 30
                                radius: 8
                                color: sell_mode ? Qt.darker(
                                                       theme.redColor) : theme.backgroundColor
                                border.color: sell_mode ? theme.redColor : theme.dexBoxBackgroundColor
                                Rectangle {
                                    anchors.left: parent.left
                                    color: parent.color
                                    height: parent.height
                                    width: parent.radius
                                    border.color: parent.border.color
                                    border.width: parent.border.width
                                    Rectangle {
                                        anchors.right: parent.right
                                        color: parent.color
                                        height: parent.height - (parent.border.width * 2)
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 2
                                    }
                                }
                                DefaultText {
                                    anchors.centerIn: parent

                                    opacity: sell_mode ? 1 : .5
                                    text: "Sell "+left_ticker
                                    color: sell_mode? Qaterial.Colors.white : theme.foregroundColor

                                }
                                DefaultMouseArea {
                                    anchors.fill: parent
                                    id: sellSelector
                                    onClicked: setMarketMode(MarketMode.Sell)
                                }
                            }
                        }
                    }
                    ItemBox {
                        expandedVert: true
                        hideHeader: true
                        title: "Form"
                        minimumHeight: 300
                        ColumnLayout {
                            property int space: 10
                            anchors.fill: parent
                            anchors.topMargin: 5
                            spacing: 10
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                visible: API.app.trading_pg.preffered_order.price !== undefined
                                Rectangle {
                                    width: parent.width - 20
                                    height: 40
                                    color: 'transparent'
                                    radius: 8
                                    border.color: theme.redColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    y: 5
                                    DefaultText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        leftPadding: 15
                                        color: theme.redColor
                                        text: qsTr("Order Selected")
                                    }
                                    Qaterial.FlatButton {
                                        foregroundColor: theme.redColor
                                        icon.source: Qaterial.Icons.close
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        height: 40
                                        width: 40
                                        anchors.rightMargin: 15
                                        onClicked: API.app.trading_pg.reset_order()
                                    }
                                }
                            }

                            OrderForm {
                                id: form_base
                                Layout.fillWidth: true
                                Layout.leftMargin: 10
                                Layout.rightMargin: 10
                                Layout.preferredHeight: 200
                                border.color: 'transparent'
                                color: 'transparent'
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Item {

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.leftMargin: 10
                                Layout.rightMargin: 10
                                Column {
                                    anchors.fill: parent
                                    anchors.leftMargin: 5
                                    anchors.rightMargin: 5
                                    FeeInfo {
                                        id: bg
                                        visible: false
                                    }
                                    spacing: 15

                                    // Trade button
                                    DefaultButton {
                                        width: parent.width - 20
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        button_type: sell_mode ? "danger" : "primary"

                                        text: qsTr("Start Swap")
                                        font.weight: Font.Medium
                                        enabled: form_base.can_submit_trade
                                        onClicked: confirm_trade_modal.open()
                                    }

                                    Column {
                                        spacing: parent.spacing
                                        visible: errors.text_value !== ""
                                        width: parent.width
                                        bottomPadding: 10
                                        HorizontalLine {
                                            Layout.fillWidth: true
                                            Layout.bottomMargin: layout_margin
                                        }

                                        // Show errors
                                        DefaultText {
                                            id: errors
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: parent.width
                                            horizontalAlignment: DefaultText.AlignHCenter
                                            font.pixelSize: Style.textSizeSmall4
                                            color: theme.redColor

                                            text_value: General.getTradingError(
                                                            last_trading_error,
                                                            curr_fee_info,
                                                            base_ticker,
                                                            rel_ticker)
                                        }
                                    }
                                }
                            }
                            Item {}
                        }
                    }
                    ItemBox {
                        id: _best_order_box2
                        visible: !isUltraLarge
                        SplitView.fillWidth: true
                        SplitView.fillHeight: true
                        defaultHeight: 250
                        minimumHeight: 130
                        //clip: true
                        //smooth: true
                        title: "Best Orders"
                        reloadable: true
                        onReload: {
                            API.app.trading_pg.orderbook.refresh_best_orders()
                        }

                        Behavior on SplitView.preferredWidth {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                        BestOrder.List {
                            clip: !parent.contentVisible
                            id: best_order_list2
                            visible: parent.contentVisible
                            y: 40
                            width: parent.width
                            height: parent.height-40
                        }
                    }
                }
            }
        }

        ModalLoader {
            id: confirm_trade_modal
            sourceComponent: ConfirmTradeModal {}
        }


    }

    TradeViewHeader {
        y: -20
    }
}
