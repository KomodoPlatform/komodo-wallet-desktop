import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0

import "../" as OtherPage

import "../../Components"
import "../../Constants"
import "../../Wallet"

// Trade Form / Component import
import "TradeBox/"
import "Trading/"
import "Trading/Items/"

// OrderBook / Component import
import "OrderBook/"

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
    property bool isUltraLarge: width>1400
    onIsUltraLargeChanged:  {
        if(isUltraLarge) {
            API.app.trading_pg.orderbook.asks.proxy_mdl.qml_sort(0, Qt.DescendingOrder)
        }else {
            API.app.trading_pg.orderbook.asks.proxy_mdl.qml_sort(0, Qt.AscendingOrder)
        }
    }

    readonly property bool block_everything: swap_cooldown.running || fetching_multi_ticker_fees_busy

    readonly property bool fetching_multi_ticker_fees_busy: API.app.trading_pg.fetching_multi_ticker_fees_busy
    readonly property alias multi_order_enabled: multi_order_switch.checked

    signal prepareMultiOrder()
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

    property bool sell_mode: API.app.trading_pg.market_mode.toString()==="Sell"
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

    property var onOrderSuccess: () => {
        General.prevent_coin_disabling.restart()
        tabView.currentIndex = 1
        flick_scrollBar.down()
        multi_order_switch.checked = API.app.trading_pg.multi_order_enabled
    }

    onSell_modeChanged: {
        reset()
    }

    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === idx_exchange_trade
    }

    function reset() {
        //API.app.trading_pg.multi_order_enabled = false
        multi_order_switch.checked = API.app.trading_pg.multi_order_enabled

    }

    readonly property var preffered_order: API.app.trading_pg.preffered_order

    function selectOrder(is_asks, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer) {
        setMarketMode(!is_asks ? MarketMode.Sell : MarketMode.Buy)

        API.app.trading_pg.preffered_order = { coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer }

        form_base.focusVolumeField()
    }

    // Cache Trade Info
    property bool valid_fee_info: API.app.trading_pg.fees.base_transaction_fees !== undefined
    readonly property var curr_fee_info: API.app.trading_pg.fees

    // Trade
    function onOpened(ticker="") {
        if(!General.initialized_orderbook_pair) {
            General.initialized_orderbook_pair = true
            API.app.trading_pg.set_current_orderbook(General.default_base, General.default_rel)
        }

        reset()
        setPair(true, ticker)
        console.log("HERE")
        console.log(base_ticker,rel_ticker)
        app.pairChanged(base_ticker, rel_ticker)
    }

    function setPair(is_left_side, changed_ticker) {
        swap_cooldown.restart()

        if(API.app.trading_pg.set_pair(is_left_side, changed_ticker))
            pairChanged(base_ticker, rel_ticker)
    }

    function trade(options, default_config) {
        // Will move to backend - nota, conf
        let nota = ""
        let confs = ""

        if(options.enable_custom_config) {
            if(options.is_dpow_configurable) {
                nota = options.enable_dpow_confs ? "1" : "0"
            }

            if(nota !== "1") {
                confs = options.required_confirmation_count.toString()
            }
        }
        else {
            if(General.exists(default_config.requires_notarization)) {
                nota = default_config.requires_notarization ? "1" : "0"
            }

            if(nota !== "1" && General.exists(default_config.required_confirmations)) {
                confs = default_config.required_confirmations.toString()
            }
        }

        if(sell_mode)
            API.app.trading_pg.place_sell_order(nota, confs)
        else
            API.app.trading_pg.place_buy_order(nota, confs)
    }

    readonly property bool buy_sell_rpc_busy: API.app.trading_pg.buy_sell_rpc_busy
    readonly property var buy_sell_last_rpc_data: API.app.trading_pg.buy_sell_last_rpc_data

    onBuy_sell_rpc_busyChanged: {
        if(buy_sell_rpc_busy) return

        const response = General.clone(buy_sell_last_rpc_data)

        if(response.error_code) {
            confirm_trade_modal.close()

            toast.show(qsTr("Failed to place the order"), General.time_toast_important_error, response.error_message)

            return
        }
        else if(response.result && response.result.uuid) { // Make sure there is information
            confirm_trade_modal.close()

            toast.show(qsTr("Placed the order"), General.time_toast_basic_info, General.prettifyJSON(response.result), false)

            General.prevent_coin_disabling.restart()
            tabView.currentIndex = 1
            //exchange.current_page = idx_exchange_orders
        }
    }

    // Form
    ColumnLayout {
        id: form

        spacing: 10
        anchors.topMargin: 40
        anchors.leftMargin: 10
        anchors.fill: parent
        Component.onCompleted: splitView.restoreState(settings.splitView)
         Component.onDestruction: settings.splitView = splitView.saveState()

         Settings {
             id: settings
             property var splitView
         }
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
                    id: safe_exchange_flickable
                    anchors.fill: parent
                    anchors.margins: 00
                    anchors.topMargin: 0
                    anchors.rightMargin: 0
                    orientation: Qt.Vertical
                    contentHeight: _content_column.height+10
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
                    function scrollToEnd(){
                        //safe_exchange_flickable.contentY = getEndPos();
                    }
                    ScrollBar.vertical: DefaultScrollBar {
                        id: flick_scrollBar
                        height: parent.height
                        anchors.right: parent.right
                        width: 4
                        function down(){
                            safe_exchange_flickable.scrollToEnd()
                        }
                    }

                    ItemBox {
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
                                    if(!block_everything)
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
                        defaultHeight: 250
                        visible: API.app.trading_pg.multi_order_enabled
                        MultiOrder {
                            anchors.topMargin: 40
                            anchors.fill: parent
                        }
                    }

                    ItemBox {
                        defaultHeight: isUltraLarge? 40 : 300
                        Behavior on defaultHeight {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                        visible: !isUltraLarge

                        width: parent.width

                        clip: true
                        OrderbookHorizontal {
                            anchors.topMargin: 40
                            anchors.fill: parent
                            visible: parent.visible
                        }
                    }
                    ItemBox {
                        defaultHeight: tabView.currentIndex===0? 200 : 400
                        clip: true
                        Column {
                            topPadding: 40
                            width: parent.width
                            height: parent.height
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
                                Material.foreground: Style.colorWhite4
                                background: Rectangle {
                                    radius: 0
                                    color: Style.colorTheme9
                                }
                                onCurrentIndexChanged: {
                                    swipeView.pop()
                                    switch(currentIndex) {
                                        case 0: swipeView.push(priceLine)
                                            break;
                                        case 1: swipeView.push(order_component)
                                            break;
                                        case 2: swipeView.push(history_component)
                                            break;
                                        default: priceLine
                                    }
                                    flick_scrollBar.down()

                                }

                                y:5
                                leftPadding: 15
                                Qaterial.TabButton {
                                    width: 150
                                    text: qsTr("Exchange Rates")
                                    foregroundColor: CheckBox? Qaterial.Style.buttonAccentColor : Style.colorWhite1
                                    opacity: checked? 1 : .6
                                }
                                Qaterial.TabButton {
                                    width: 120
                                    text: qsTr("Orders")
                                    foregroundColor: CheckBox? Qaterial.Style.buttonAccentColor : Style.colorWhite1
                                    opacity: checked? 1 : .6
                                }
                                Qaterial.TabButton {
                                    width: 120
                                    text: qsTr("history")
                                    foregroundColor: CheckBox? Qaterial.Style.buttonAccentColor : Style.colorWhite1
                                    opacity: checked? 1 : .6
                                }
                            }
                            Item {
                                anchors.horizontalCenter: parent.horizontalCenter
                                //radius: 4
                                width: parent.width
                                height: parent.height-(tabView.height+40)
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
                                        OtherPage.OrdersPage {
                                            clip: true

                                            Component.onCompleted: flick_scrollBar.down()
                                        }
                                    }
                                    Component {
                                        id: history_component
                                        OtherPage.OrdersPage {
                                            is_history: true
                                            clip: true
                                            Component.onCompleted: {
                                                flick_scrollBar.down()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
            }

            ItemBox {
                SplitView.minimumWidth: 0
                SplitView.maximumWidth: 350
                SplitView.fillHeight: true
                title: "OrderBook & Best Orders"
                color: 'transparent'
                closable: false
                visible: isUltraLarge
                SplitView {
                    anchors.topMargin: 40
                    anchors.fill: parent
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
                    Item {
                        SplitView.minimumHeight: 1
                        SplitView.maximumHeight: 1
                        SplitView.fillWidth: true
                    }
                    ItemBox {
                        SplitView.fillWidth: true
                        //defaultWidth: isUltraLarge? 350 : 0
                        clip: true
                        title: "OrderBook"

                        Behavior on SplitView.preferredWidth {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                        OrderbookVertical {
                            visible: parent.contentVisible
                            anchors.topMargin: 40
                            anchors.fill: parent
                        }
                    }
                    ItemBox {
                        SplitView.fillWidth: true
                        //defaultWidth: isUltraLarge? 350 : 0
                        SplitView.fillHeight: true
                        defaultHeight: 300
                        clip: true
                        title: "Best Orders"
                        Behavior on SplitView.preferredWidth {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                        OrderbookVertical {
                            visible: parent.contentVisible
                            anchors.topMargin: 40
                            anchors.fill: parent
                        }
                    }
                }




            }

            ItemBox {
                defaultWidth: 300
                maximumWidth: 300
                SplitView.fillHeight: true
                title: "Buy & Sell"
                color: 'transparent'
                border.color: 'transparent'
                clip: true
                SplitView {
                    visible: parent.contentVisible
                    orientation: Qt.Vertical
                    anchors.fill: parent
                    anchors.topMargin: 40
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
                        clip: true
                        visible: true
                        TotalView {

                        }
                    }
                    Item {
                        SplitView.fillWidth: true
                        SplitView.preferredHeight: 30
                        SplitView.maximumHeight: 35
                        Row {
                            width: parent.width-120
                            anchors.centerIn: parent
                            Rectangle {
                                width: (parent.width/2)
                                height: 30
                                radius: 8
                                color: !sell_mode? Qt.darker(Style.colorGreen) : Style.colorTheme7
                                border.color: !sell_mode? Style.colorGreen : Style.colorWhite9
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
                                        height: parent.height-(parent.border.width*2)
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 2
                                    }
                                }
                                DefaultText {
                                    anchors.centerIn: parent
                                    font.pixelSize: Style.textSizeSmall5
                                    opacity: !sell_mode? 1 : .5
                                    text: "Buy"

                                }
                                DefaultMouseArea {
                                    anchors.fill: parent
                                    id: buySelector
                                    onClicked: setMarketMode(MarketMode.Buy)
                                }
                            }
                            Rectangle {
                                width: (parent.width/2)
                                height: 30
                                radius: 8
                                color: sell_mode? Qt.darker(Style.colorRed) : Style.colorTheme7
                                border.color: sell_mode? Style.colorRed : Style.colorWhite9
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
                                        height: parent.height-(parent.border.width*2)
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 2
                                    }
                                }
                                DefaultText {
                                    anchors.centerIn: parent
                                    font.pixelSize: Style.textSizeSmall5
                                    opacity: sell_mode? 1 : .5
                                    text: "Sell"
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
                        SplitView.fillHeight: true
                        hideHeader: true
                        title: "Form"
                        ColumnLayout {
                            property int space: 10
                            anchors.fill: parent
                            anchors.topMargin: 5
                            spacing: 10

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
                                        width: parent.width-20
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        button_type: sell_mode ? "danger" : "primary"

                                        text: qsTr("Start Swap")
                                        font.weight: Font.Medium
                                        enabled: !multi_order_enabled && form_base.can_submit_trade
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
                                            color: Style.colorRed

                                            text_value: General.getTradingError(last_trading_error, curr_fee_info, base_ticker, rel_ticker)
                                        }
                                    }
                                }
                            }
                            Item {

                            }
                        }
                    }
                    ItemBox {
                        defaultHeight: 200
                        clip: true
                        title: "Multi-Order"
                        Item {
                            anchors.fill: parent
                            anchors.topMargin: 40
                            Item {
                                visible: sell_mode
                                width: parent.width
                                height: multi_order_swith_col.height+10
                                Column {
                                    id: multi_order_swith_col
                                    width: parent.width-10
                                    padding: 5
                                    spacing: 10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    bottomPadding: 0
                                    DefaultSwitch {
                                        id: multi_order_switch
                                        Layout.fillWidth: true

                                        text: qsTr("Multi-Order")
                                        enabled: !block_everything && (form_base.can_submit_trade || checked)

                                        checked: API.app.trading_pg.multi_order_enabled
                                        onCheckedChanged: {
                                            if(checked) {
                                                setVolume(max_volume)
                                                API.app.trading_pg.multi_order_enabled = checked
                                            }else {
                                                API.app.trading_pg.multi_order_enabled = checked
                                            }
                                        }
                                    }

                                    DefaultText {
                                        width: parent.width-20
                                        wrapMode: Label.Wrap
                                        text_value: qsTr("Select additional assets for multi-order creation.")
                                        font.pixelSize: Style.textSizeSmall2
                                    }

                                    DefaultText {
                                        width: parent.width-10
                                        wrapMode: Label.Wrap
                                        font.pixelSize: Style.textSizeSmall2
                                        text_value: qsTr("Same funds will be used until an order matches.")
                                    }

                                    DefaultButton {
                                        text: qsTr("Submit Trade")
                                        width: parent.width-10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        enabled: multi_order_enabled && form_base.can_submit_trade
                                        onClicked: {
                                            multi_order_values_are_valid = true
                                            prepareMultiOrder()
                                            if(multi_order_values_are_valid)
                                                confirm_multi_order_trade_modal.open()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ModalLoader {
            id: confirm_trade_modal
            sourceComponent: ConfirmTradeModal {}
        }

        ModalLoader {
            id: confirm_multi_order_trade_modal
            sourceComponent: ConfirmMultiOrderTradeModal {}
        }
    }
    Popup {
        id: p
        width: 260
        height: 250
        x: parent.width-340
        y: 35
        background: FloatingBackground {}

        Column {
            id: popup_column
            width: 250
            anchors.horizontalCenter: parent.horizontalCenter
            padding: 10
            topPadding: 2
            RowLayout {
                width: parent.width-20
                height: 40
                anchors.margins: 5
                DefaultText {
                    Layout.alignment: Qt.AlignVCenter
                    text: "Length"
                }
                Item { Layout.fillWidth: true; Layout.fillHeight: true }
                DefaultComboBox {
                    id: lenComboBox
                    model: ["default","0,01","0,001","0,0001","0,00001","0,000001","0,0000001","0,00000001"]
                }
            }
        }
    }

    TradeViewHeader {
        y: -20
    }
}
