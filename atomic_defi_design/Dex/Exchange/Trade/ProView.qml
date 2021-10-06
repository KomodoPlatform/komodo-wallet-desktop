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

ColumnLayout {
    id: form
    property alias dexConfig: dex_config_popup
    function selectOrder(is_asks, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume, base_min_volume, base_max_volume, rel_min_volume, rel_max_volume, base_max_volume_denom, base_max_volume_numer, uuid) {
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
    spacing: 10
    anchors.topMargin: 20
    anchors.leftMargin: 10
    anchors.fill: parent
    Connections {
        target: app
        function onPairChanged(base, rel) {
            dex_chart.visible = true
        }
    }

    DexBoxManager {
        id: splitView
        Layout.fillWidth: true
        Layout.fillHeight: true
        itemLists: [left_section, order_form]
        spacing: 15
        handle: Item {
            implicitWidth: 2
            implicitHeight: 4
            Rectangle {
                implicitWidth: 2
                implicitHeight: 4
                anchors.centerIn: parent
                opacity: 0
                color: 'transparent'
            }
        }

        DexTradeBox {
            id: left_section
            minimumWidth: 550
            defaultWidth: 560
            expandedHort: true
            hideHeader: true
            SplitView.fillHeight: true
            color: 'transparent'
            DexBoxManager {
                anchors.fill: parent
                anchors.margins: 0
                anchors.rightMargin: 0
                orientation: Qt.Vertical
                handle: Item {
                    implicitWidth: 40
                    implicitHeight: 6
                    InnerBackground {
                        implicitWidth: 40
                        implicitHeight: 6
                        anchors.centerIn: parent
                        opacity: 0.4
                    }
                }
                itemLists: [dex_chart, optionBox]
                DexTradeBox {
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
                DexTradeBox {
                    canBeFull: true
                    hideHeader: true
                    maximumHeight: 80
                    minimumHeight: 75
                    RowLayout {
                        id: selectors
                        spacing: 20
                        anchors.fill: parent
                        anchors.rightMargin: 10
                        anchors.leftMargin: 10
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

                }

                
                DexTradeBox {
                    id: optionBox
                    expandedVert: dex_chart.visible? false : true
                    expandable: true
                    defaultHeight: tabView.currentIndex === 0 ? 200 : isUltraLarge? 400 : 270
                    Connections {
                        target: tabView
                        function onCurrentIndexChanged() {
                            if (tabView.currentIndex !== 0) {
                                optionBox.setHeight(isUltraLarge? 400 : 270)
                            } else {
                                optionBox.setHeight(200)
                            }
                        }
                    }
                    closable: true
                    title: qsTr("Trading Information")
                    Column {
                        topPadding: 40
                        width: parent.width
                        height: parent.height
                        clip: !parent.contentVisible
                        anchors.horizontalCenter: parent.horizontalCenter
                        Qaterial.LatoTabBar {
                            z: 4
                            id: tabView
                            property int taux_exchange: 0
                            property int order_idx: 1
                            property int history_idx: 2
                            width: parent.width
                            currentIndex: tabView.currentIndex
                            anchors.horizontalCenter: parent.horizontalCenter
                            Material.foreground: DexTheme.foregroundColor
                            background: Rectangle {
                                radius: 0
                                color: DexTheme.portfolioPieGradient ? "transparent" : DexTheme.dexBoxBackgroundColor
                            }

                            y: 5
                            leftPadding: 15
                            Qaterial.LatoTabButton {
                                width: 150
                                text: qsTr("Exchange Rates")
                                font.pixelSize: 14
                                textColor: checked ? Qaterial.Style.buttonAccentColor : DexTheme.foregroundColor
                                textSecondaryColor: DexTheme.foregroundColorLightColor0
                                opacity: checked ? 1 : .6
                            }
                            Qaterial.LatoTabButton {
                                width: 120
                                text: qsTr("Orders")
                                font.pixelSize: 14
                                textColor: checked ? Qaterial.Style.buttonAccentColor : DexTheme.foregroundColor
                                textSecondaryColor: DexTheme.foregroundColorLightColor0
                                opacity: checked ? 1 : .6
                            }
                            Qaterial.LatoTabButton {
                                width: 120
                                text: qsTr("History")
                                font.pixelSize: 14
                                textColor: checked ? Qaterial.Style.buttonAccentColor : DexTheme.foregroundColor
                                textSecondaryColor: DexTheme.foregroundColorLightColor0
                                opacity: checked ? 1 : .6
                            }
                        }
                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            height: optionBox.height - (tabView.height + 40)
                            SwipeView {
                                id: swipeView
                                clip: true
                                interactive: false
                                currentIndex: tabView.currentIndex
                                anchors.fill: parent
                                onCurrentIndexChanged: {
                                    swipeView.currentItem.update()
                                    if(currentIndex===2) {
                                        history_component.list_model_proxy.is_history = true
                                    } else {
                                        history_component.list_model_proxy.is_history = false
                                    }
                                }

                                PriceLine {
                                    id: price_line_obj
                                }

                                OrdersView.OrdersPage {
                                    id: order_component
                                    clip: true
                                }
                                OrdersView.OrdersPage {
                                    id: history_component
                                    is_history: true
                                    clip: true
                                }
                            }
                        }
                    }
                }
                Item {
                    SplitView.maximumHeight: 1
                }
            }
        }
        Item {
            id: _book_and_best
            property bool showing: (_best_order_box.visible || _orderbook_box.visible)
            SplitView.minimumWidth: showing? 320 : 0
            SplitView.maximumWidth: showing? 330 : 0
            SplitView.preferredWidth: showing? 280 : 0
            clip: true
            DexBoxManager {
                anchors.fill: parent
                orientation: Qt.Vertical
                handle: Item {
                    implicitWidth: 40
                    implicitHeight: 6
                    InnerBackground {
                        implicitWidth: 40
                        implicitHeight: 6
                        anchors.centerIn: parent
                        opacity: 0.4
                    }
                }
                itemLists: [_orderbook_box, _best_order_box]
                DexTradeBox {
                    id: _orderbook_box
                    SplitView.fillWidth: true
                    closable: true
                    title: qsTr("Order Book")
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
                DexTradeBox {
                    id: _best_order_box
                    defaultHeight: 250
                    minimumHeight: 130
                    closable: true
                    title: qsTr("Best Orders")
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

        DexTradeBox {
            id: order_form
            closable: true
            title: qsTr("Place Order")
            defaultWidth: isBigScreen? 300 : 280
            maximumWidth: isBigScreen? 310 : 280
            minimumWidth: isBigScreen? 290 : 280
            expandable: false
            SplitView.fillHeight: true
            ColumnLayout {
                visible: parent.contentVisible
                anchors.topMargin: 60
                anchors.fill: parent
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 35
                    Gradient {
                        id: activeGradient
                        orientation: Qt.Horizontal
                        GradientStop {
                            position: 0.1255
                            color: DexTheme.buttonGradientEnabled1
                        }
                         GradientStop {
                            position: 0.933
                            color: DexTheme.buttonGradientEnabled2
                        }
                    }

                    Gradient {
                        id: activeRedGradient
                        orientation: Qt.Horizontal
                        GradientStop {
                            position: 0.1255
                            color: DexTheme.redColor
                        }
                         GradientStop {
                            position: 0.933
                            color: Qt.darker(DexTheme.redColor, 0.8)
                        }
                    }

                    Row {
                        width: parent.width - 60
                        spacing: 10
                        anchors.centerIn: parent
                        Rectangle {
                            width: (parent.width / 2)
                            height: 40
                            radius: 15
                            color: !sell_mode ? Qt.darker(
                                                    DexTheme.greenColor) : Qt.lighter(DexTheme.dexBoxBackgroundColor)
                            gradient: DexTheme.portfolioPieGradient && !sell_mode ? activeGradient : undefined
                            border.color: !sell_mode ? "transparent" : DexTheme.greenColor
                            DefaultText {
                                anchors.centerIn: parent
                                opacity: !sell_mode ? 1 : .5
                                text: qsTr("Buy")+" "+atomic_qt_utilities.retrieve_main_ticker(left_ticker)
                                color: !sell_mode? Qaterial.Colors.white : DexTheme.foregroundColor
                            }
                            DefaultMouseArea {
                                anchors.fill: parent
                                id: buySelector
                                onClicked: setMarketMode(MarketMode.Buy)
                            }
                        }

                        Rectangle {
                            width: (parent.width / 2)
                            height: 40
                            radius: 15
                            color: sell_mode ? Qt.darker(
                                                   DexTheme.redColor) : Qt.lighter(DexTheme.dexBoxBackgroundColor)
                            border.color: sell_mode ? "transparent" : DexTheme.redColor
                            gradient: DexTheme.portfolioPieGradient && sell_mode ? activeRedGradient : undefined
                            DefaultText {
                                anchors.centerIn: parent

                                opacity: sell_mode ? 1 : .5
                                text: qsTr("Sell")+" "+atomic_qt_utilities.retrieve_main_ticker(left_ticker)
                                color: sell_mode? Qaterial.Colors.white : DexTheme.foregroundColor

                            }
                            DefaultMouseArea {
                                anchors.fill: parent
                                id: sellSelector
                                onClicked: setMarketMode(MarketMode.Sell)
                            }
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                                border.color: DexTheme.redColor
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 5
                                DefaultText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    leftPadding: 15
                                    color: DexTheme.redColor
                                    text: qsTr("Order Selected")
                                }
                                Qaterial.FlatButton {
                                    foregroundColor: DexTheme.redColor
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
                            Layout.preferredHeight: 270
                            border.color: 'transparent'
                            color: 'transparent'
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Item {
                            Layout.preferredHeight: 90
                            Layout.fillWidth: true
                            TotalView {}
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
                                DexGradientAppButton {
                                    width: parent.width - 20
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    gradient: sell_mode ? activeRedGradient : activeGradient
                                    opacity: enabled ? containsMouse ? .7: 1 : .5

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
                                        color: DexTheme.redColor

                                        text_value: General.getTradingError(
                                                        last_trading_error,
                                                        curr_fee_info,
                                                        base_ticker,
                                                        rel_ticker, left_ticker, right_ticker)
                                    }
                                }
                            }
                        }
                        Item {}
                    }
                }
            }
        }
    }

    ModalLoader {
        id: confirm_trade_modal
        sourceComponent: ConfirmTradeModal {}
    }
    DexPopup {
        id: dex_config_popup
        spacing: 8
        padding: 4
        arrowXDecalage: 75
        backgroundColor: DexTheme.dexBoxBackgroundColor
        Settings {
            id: proview_settings
            property bool chart_visibility: true
            property bool option_visibility: true
            property bool orderbook_visibility: true
            property bool best_order_visibility: false
            property bool form_visibility: true
        }

        contentItem: Item {
            implicitWidth: 350
            implicitHeight: 190
            Column {
                anchors.fill: parent
                rightPadding: 20
                padding: 10
                spacing: 8
                DexLabel {
                    text: "Display Settings"
                    font: DexTypo.body2
                }
                HorizontalLine { width: parent.width-20;anchors.horizontalCenter: parent.horizontalCenter;opacity: .4 }
                DexCheckEye {
                    text: "Trading Information"
                    targetProperty: "visible"
                    target: optionBox
                }
                HorizontalLine { width: parent.width-20;anchors.horizontalCenter: parent.horizontalCenter;opacity: .4 }
                DexCheckEye {
                    text: "Order Book"
                    targetProperty: "visible"
                    target: _orderbook_box
                }
                HorizontalLine { width: parent.width-20;anchors.horizontalCenter: parent.horizontalCenter;opacity: .4 }
                DexCheckEye {
                    text: "Best Order"
                    targetProperty: "visible"
                    target: _best_order_box
                }
                HorizontalLine { width: parent.width-20;anchors.horizontalCenter: parent.horizontalCenter;opacity: .4 }
                DexCheckEye {
                    id: place_visibility
                    text: "Place Order"
                    targetProperty: "visible"
                    target: order_form
                }
            }
            Component.onCompleted: {
                dex_chart.visible = proview_settings.chart_visibility
                optionBox.visible = proview_settings.option_visibility
                _orderbook_box.visible = proview_settings.orderbook_visibility
                _best_order_box.visible = proview_settings.best_order_visibility
                order_form.visible = proview_settings.form_visibility
            }
            Component.onDestruction: {
                proview_settings.form_visibility = order_form.visible
                proview_settings.chart_visibility = dex_chart.visible
                proview_settings.option_visibility = optionBox.visible
                proview_settings.orderbook_visibility = _orderbook_box.visible 
                proview_settings.best_order_visibility = _best_order_box.visible
            }
        }
    }


}
