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

ColumnLayout {
    id: form
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
    Connections {
        target: exchange_trade
        function onBuy_sell_rpc_busyChanged() {
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
    }
    Connections {
        target:exchange_trade
    }

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
            defaultWidth: 380
            maximumWidth: 380
            minimumWidth: 350
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
                                text: "Buy "+atomic_qt_utilities.retrieve_main_ticker(left_ticker)
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
                                text: "Sell "+atomic_qt_utilities.retrieve_main_ticker(left_ticker)
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
