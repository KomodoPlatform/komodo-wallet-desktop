//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! 3rdParty Imports
import Qaterial 1.0 as Qaterial

//! Project Imports
import AtomicDEX.TradingError 1.0
import AtomicDEX.SelectedOrderStatus 1.0
import "../../../Components"
import "../../../Constants" as Constants
import "../"
import Dex.Themes 1.0 as Dex
import App 1.0

ClipRRect // Trade Card
{
    id: _tradeCard

    property string selectedTicker: API.app.get_balance(left_ticker) > 0 ? left_ticker : ""
    property var    selectedOrder:  undefined
    property bool   best: false
    property bool   coinSelection: false
    property bool   has_coins_with_balance: API.app.has_coins_with_balance()

    onSelectedTickerChanged: { selectedOrder = undefined; setPair(true, selectedTicker); _fromValue.text = "" }

    onSelectedOrderChanged:
    {
        if (typeof selectedOrder !== 'undefined' && selectedOrder.from_best_order) Constants.API.app.trading_pg.orderbook.select_best_order(selectedOrder.uuid)
        else if (typeof selectedOrder !== 'undefined') Constants.API.app.trading_pg.preffered_order = selectedOrder
        else Constants.API.app.trading_pg.reset_order()

        Constants.API.app.trading_pg.determine_fees()
    }

    onEnabledChanged: selectedOrder = undefined
    Component.onDestruction: selectedOrder = undefined
    Component.onCompleted: _fromValue.forceActiveFocus()
    onBestChanged: if (best) Constants.API.app.trading_pg.orderbook.refresh_best_orders()

    width: bestOrderSimplified.visible ? 600 : coinSelection ? 450 : 380
    height: swap_card_content.height + 15
    radius: 20

    Connections // Catches C++ `trading_page` class signals.
    {
        enabled: parent.enabled
        target: Constants.API.app.trading_pg

        function onSelectedOrderStatusChanged() // When the selected order status has changed.
        {
            if (Constants.API.app.trading_pg.selected_order_status == SelectedOrderStatus.OrderNotExistingAnymore)
            {
                _orderDisappearModalLoader.open()
                _confirmSwapModal.close()
            }
        }

        function onPreferredOrderChangeFinished()   // When selected order has changed
        {
            if (typeof selectedOrder === 'undefined')
                return
            if (parseFloat(_fromValue.text) > Constants.API.app.trading_pg.max_volume)
                _fromValue.text = Constants.API.app.trading_pg.max_volume
        }

        function onVolumeChanged()
        {
            _fromValue.text = Constants.API.app.trading_pg.volume
        }
    }

    Connections
    {
        target: Constants.API.app.trading_pg.orderbook.bids

        function onBetterOrderDetected(newOrder)
        {
            if (!selectedOrder) return
            // We shoould rename SelectedOrderStatus enum to OrderbookNotification.
            if (Constants.API.app.trading_pg.selected_order_status == SelectedOrderStatus.BetterPriceAvailable)
            {
                // Price changed and we can still afford the volume.
                if (parseFloat(newOrder.base_max_volume) <= selectedOrder.base_max_volume && parseFloat(newOrder.rel_max_volume) >= Constants.API.app.trading_pg.total_amount)
                {
                    console.log("Updating forms with better price");
                    Qaterial.SnackbarManager.show(
                    {
                        expandable: true,
                        text: qsTr("Better price found: %1. Updating forms.")
                                    .arg(parseFloat(newOrder.price).toFixed(8)),
                        timeout: Qaterial.Constants.Style.snackbar.longDisplayTime
                    })
                    selectedOrder = newOrder
                }
                else
                {
                    console.log("Asking user if he want a better price but lower volume");
                    Qaterial.SnackbarManager.show(
                    {
                        expandable: true,
                        action: "Update",
                        text: qsTr("Better price (%1) found but received quantity (%2) is lower than your current one (%3). Click here to update the selected order.")
                                    .arg(parseFloat(newOrder.price).toFixed(8))
                                    .arg(parseFloat(newOrder.rel_max_volume).toFixed(8))
                                    .arg(Constants.API.app.trading_pg.total_amount),
                        onAccept: function() { selectedOrder = newOrder },
                        onClose:  function() { selectedOrder = undefined },
                        maximumLineCount: 2,
                        timeout: 10000
                    })
                }
            }
        }
    }

    ModalLoader
    {
        id: _orderDisappearModalLoader
        sourceComponent: OrderRemovedModal {}
        onLoaded: selectedOrder = undefined
    }

    MouseArea // Swap Card Mouse Area
    {
        anchors.fill: parent
        onPressed: _fromValue.focus = false // When clicking outside `_fromValue` TextField, `fromValue` losts its focus.
    }

    Column    // Swap Card Content
    {
        id: swap_card_content

        width: parent.width
        Column // Header
        {
            id: _swapCardHeader

            width: parent.width - 20
            leftPadding: 20
            topPadding: 20
            bottomPadding: 20
            spacing: 15

            DexLabel // Title
            {
                text: qsTr("Swap")
                font: DexTypo.head6
                opacity: .85
            }

            DefaultText // Description
            {
                anchors.topMargin: 10
                font.pixelSize: Constants.Style.textSizeSmall4
                text: qsTr("Instant trading with best orders")

                Qaterial.AppBarButton // Reset Form Button
                {
                    enabled: !coinSelection && !best && typeof selectedOrder !== 'undefined'
                    visible: enabled

                    anchors.left: parent.right
                    anchors.leftMargin: 80
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -8

                    width: 50
                    height: 50

                    hoverEnabled: true

                    onClicked: selectedOrder = undefined

                    Qaterial.ColorIcon
                    {
                        anchors.centerIn: parent
                        source:  Qaterial.Icons.broom
                        color: DexTheme.foregroundColor
                        opacity: .8
                    }

                    DefaultTooltip
                    {
                        delay: 500
                        timeout: 5000
                        visible: parent.hovered
                        text: qsTr("Reset form")
                    }
                }
            }

            DexLabel // Title
            {
                text: qsTr("You have no tradable assets")
                font: DexTypo.head6
                opacity: .85
                visible: !has_coins_with_balance
            }
        }

        Item
        {
            width: _tradeCard.width
            height: .5
        }

        ColumnLayout // Content
        {
            width: parent.width

            anchors.horizontalCenter: parent.horizontalCenter

            DexRectangle // From
            {
                id: swap_from_card
                Layout.preferredWidth: _tradeCard.width - 20
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignHCenter
                radius: 20
                visible: !coinSelectorSimplified.visible && has_coins_with_balance

                DefaultText // From Text
                {
                    id: _fromTitle
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    anchors.left: parent.left
                    anchors.leftMargin: 17
                    text: qsTr("From")
                    font.pixelSize: Constants.Style.textSizeSmall4
                }

                Text // Tradable Balance
                {
                    readonly property int _maxWidth: 140

                    id: _fromBalance
                    visible: selectedTicker !== ""
                    width: Math.min(_maxWidth, _textMetrics.boundingRect.width + 10)
                    anchors.verticalCenter: _fromTitle.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 17
                    text: qsTr("%1").arg(Constants.API.app.trading_pg.max_volume)
                    font.pixelSize: Constants.Style.textSizeSmall2
                    elide: Text.ElideRight
                    color: DexTheme.foregroundColorLightColor1

                    DefaultImage
                    {
                        id: _fromBalanceIcon
                        width: 16
                        height: 16
                        anchors.right: parent.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        source: Constants.General.image_path + "menu-assets-white.svg"
                        opacity: .6
                    }

                    MouseArea
                    {
                        anchors.left: _fromBalanceIcon.left
                        anchors.right: _fromBalance.right
                        anchors.top: _fromBalance.top
                        anchors.bottom: _fromBalance.bottom
                        hoverEnabled: true
                        DefaultTooltip
                        {
                            visible: parent.containsMouse
                            text: qsTr("Tradable: ") + parent.parent.text
                        }
                    }

                    TextMetrics
                    {
                        id: _textMetrics
                        font: _fromBalance.font
                        text: _fromBalance.text
                        elide: _fromBalance.elide
                    }
                }

                AmountField // Amount
                {
                    id: _fromValue
                    enabled: selectedTicker !== ""
                    visible: enabled
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    placeholderText: Constants.API.app.trading_pg.max_volume == 0 ?
                            "Loading wallet..." : typeof selectedOrder !== 'undefined' ?
                            qsTr("Min: %1").arg(Constants.API.app.trading_pg.min_trade_vol) : qsTr("Enter an amount")
                    font.pixelSize: Constants.Style.textSizeSmall5
                    background: Rectangle { color: swap_from_card.color}

                    onTextChanged:
                    {
                        if (text === "")
                        {
                            Constants.API.app.trading_pg.volume = 0
                            text = ""
                        }
                        else Constants.API.app.trading_pg.volume = text
                    }

                    onFocusChanged:
                    {
                        if (!focus && parseFloat(text) < parseFloat(Constants.API.app.trading_pg.min_trade_vol))
                        {
                            text = Constants.API.app.trading_pg.min_trade_vol
                        }
                    }
                    Component.onCompleted: text = ""
                }

                Text    // Amount In Fiat
                {
                    enabled: _fromValue.text
                    visible: enabled
                    anchors.top: _fromValue.bottom
                    anchors.topMargin: -3
                    anchors.left: _fromValue.left
                    anchors.leftMargin: 24
                    font.pixelSize: Constants.Style.textSizeSmall1
                    color: DexTheme.foregroundColor
                    opacity: .9
                    text: enabled ? Constants.General.getFiatText(_fromValue.text, selectedTicker) : ""
                }

                Rectangle // Select ticker button
                {
                    id: _selectTickerBut

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.right: parent.right
                    anchors.rightMargin: 20

                    width: (_selectedTickerIcon.enabled ? _selectedTickerIcon.width : 0) + Math.max(_selectedTickerText.implicitWidth, _selectedTickerTypeText.implicitWidth) + _selectedTickerArrow.width + 29.5

                    height: 30

                    radius: 10
                    border.width: 0
                    color: _selectedTickerMouseArea.containsMouse ?
                                Dex.CurrentTheme.buttonColorHovered :
                                swap_from_card.color

                    DefaultMouseArea
                    {
                        id: _selectedTickerMouseArea
                        anchors.fill: parent
                        onClicked:
                        {
                            _tradeCard.coinSelection = true
                            _tradeCard.best = false
                        }
                        hoverEnabled: true
                    }

                    DefaultImage
                    {
                        id: _selectedTickerIcon
                        enabled: selectedTicker !== ""
                        visible: enabled
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        width: 20
                        height: 20
                        source: Constants.General.coinIcon(selectedTicker)
                    }

                    DefaultText
                    {
                        id: _selectedTickerText

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: _selectedTickerIcon.enabled ? -5 : 0
                        anchors.left: _selectedTickerIcon.right
                        anchors.leftMargin: _selectedTickerIcon.enabled ? 10 : -10

                        width: 60

                        text: _selectedTickerIcon.enabled ? atomic_qt_utilities.retrieve_main_ticker(selectedTicker) : qsTr("Pick a coin")
                        font.pixelSize: Constants.Style.textSizeSmall2

                        wrapMode: Text.NoWrap

                        DefaultText
                        {
                            id: _selectedTickerTypeText

                            enabled: _selectedTickerIcon.enabled
                            visible: enabled

                            anchors.top: parent.bottom

                            text: Constants.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(selectedTicker).type
                            font.pixelSize: 9
                        }
                    }

                    Arrow
                    {
                        id: _selectedTickerArrow

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 5

                        up: false
                    }
                }

                ClickableText // MAX Button
                {
                    id: _maxClickableLabel

                    anchors.right: _selectTickerBut.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: _selectTickerBut.verticalCenter

                    visible: selectedTicker !== ""

                    text: qsTr("MAX")
                    color: Dex.CurrentTheme.foregroundColor2

                    onClicked: _fromValue.text = Constants.API.app.trading_pg.max_volume
                }

                DefaultBusyIndicator
                {
                    anchors.centerIn: parent
                    visible: selectedTicker !== "" && Constants.API.app.trading_pg.max_volume == 0
                }
            }

            DexRectangle // To
            {
                Layout.preferredWidth: _tradeCard.width - 20
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                radius: 20
                color: DexTheme.tradeFieldBoxBackgroundColor
                visible: !bestOrderSimplified.visible
                    && !coinSelectorSimplified.visible
                    && has_coins_with_balance

                DefaultText
                {
                    anchors.fill: parent
                    anchors.leftMargin: 17
                    anchors.topMargin: 14
                    text: qsTr("To")
                    font.pixelSize: Constants.Style.textSizeSmall4
                }

                AmountField // Amount
                {
                    id: _toValue
                    enabled: false
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    text: Constants.API.app.trading_pg.total_amount
                    color: Dex.CurrentTheme.textDisabledColor
                    font.pixelSize: Constants.Style.textSizeSmall5
                    background: Rectangle { color: swap_from_card.color}
                }

                DefaultText // Amount In Fiat
                {
                    enabled: parseFloat(_toValue.text) > 0
                    anchors.top: _toValue.bottom
                    anchors.topMargin: -3
                    anchors.left: _toValue.left
                    anchors.leftMargin: 24
                    font.pixelSize: Constants.Style.textSizeSmall1
                    opacity: .9
                    text: enabled ? Constants.General.getFiatText(_toValue.text, _tradeCard.selectedOrder.coin?? "") : ""
                }

                Rectangle // Shows best order coin
                {
                    id: _selectBestOrderButton

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.right: parent.right
                    anchors.rightMargin: 20

                    height: 30
                    width: _bestOrderIcon.enabled ?
                               _bestOrderIcon.width + Math.max(_bestOrderTickerText.implicitWidth, _bestOrderTickerTypeText.implicitWidth) + _bestOrderArrow.width + 29.5 :
                               _bestOrderNoTickerText.implicitWidth + 30

                    radius: 10
                    border.width: 0

                    color: _bestOrdersMouseArea.containsMouse ? Dex.CurrentTheme.buttonColorHovered : swap_from_card.color
                    opacity: _bestOrdersMouseArea.enabled ? 1 : 0.3

                    DefaultMouseArea
                    {
                        id: _bestOrdersMouseArea

                        anchors.fill: parent

                        enabled: parseFloat(_fromValue.text) > 0

                        hoverEnabled: true

                        onClicked: _tradeCard.best = true
                    }

                    // When no order is currently selected.
                    DefaultText
                    {
                        id: _bestOrderNoTickerText

                        enabled: !_bestOrderIcon.enabled
                        visible: enabled

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left

                        text: qsTr("Pick an order")
                        font.pixelSize: Constants.Style.textSizeSmall2
                    }

                    // Token Icon (When a best order is currently selected)
                    DefaultImage
                    {
                        id: _bestOrderIcon

                        enabled: typeof selectedOrder !== 'undefined'
                        visible: enabled

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left

                        width: 20
                        height: 20

                        source: enabled ? Constants.General.coinIcon(selectedOrder.coin) : ""
                    }

                    // Ticker (When a best order is currently selected)
                    DefaultText
                    {
                        id: _bestOrderTickerText

                        enabled: _bestOrderIcon.enabled
                        visible: _bestOrderIcon.visible

                        anchors.verticalCenter: _bestOrderIcon.verticalCenter
                        anchors.verticalCenterOffset: -5
                        anchors.left: _bestOrderIcon.right
                        anchors.leftMargin: 10
                        width: 60

                        text: enabled ? atomic_qt_utilities.retrieve_main_ticker(selectedOrder.coin) : ""
                        font.pixelSize: Constants.Style.textSizeSmall2
                        wrapMode: Text.NoWrap

                        DefaultText
                        {
                            id: _bestOrderTickerTypeText

                            anchors.top: parent.bottom

                            text: enabled ? Constants.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(selectedOrder.coin).type : ""
                            font.pixelSize: 9
                        }
                    }

                    Arrow
                    {
                        id: _bestOrderArrow

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 5

                        up: false
                    }
                }
            }

            RowLayout // Unit Price
            {
                id: _unitPrice

                // LAYOUT
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true

                enabled: typeof selectedOrder !== 'undefined'
                visible: enabled
                        && !bestOrderSimplified.visible
                        && !coinSelectorSimplified.visible
                        && has_coins_with_balance

                DefaultText
                {
                    Layout.rightMargin: 120
                    font.pixelSize: Constants.Style.textSizeSmall3
                    text: qsTr("Price")
                }

                DefaultText
                {
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: Constants.Style.textSizeSmall3
                    text: selectedOrder ? "1 %1 = %2 %3"
                                            .arg(atomic_qt_utilities.retrieve_main_ticker(selectedTicker))
                                            .arg(parseFloat(Constants.API.app.trading_pg.price).toFixed(8))
                                            .arg(atomic_qt_utilities.retrieve_main_ticker(selectedOrder.coin))
                                        : ""
                }
            }

            Item // Swap Button
            {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: _tradeCard.width - 30
                Layout.preferredHeight: 50
                visible: !bestOrderSimplified.visible
                    && !coinSelectorSimplified.visible
                    && has_coins_with_balance

                DexGradientAppButton
                {
                    enabled: !Constants.API.app.trading_pg.preimage_rpc_busy && !_swapAlert.visible
                    opacity: enabled ? 1 : .6
                    radius: 10
                    anchors.fill: parent
                    text: qsTr("SWAP NOW")
                    onClicked: _confirmSwapModal.open()

                    ModalLoader
                    {
                        id: _confirmSwapModal
                        sourceComponent: ConfirmTradeModal {}
                    }

                    Connections
                    {
                        target: exchange_trade
                        function onBuy_sell_rpc_busyChanged()
                        {
                            if (buy_sell_rpc_busy)
                                return

                            const response = Constants.General.clone(buy_sell_last_rpc_data)

                            if (response.error_code)
                            {
                                _confirmSwapModal.close()

                                toast.show(qsTr("Failed to place the order"),
                                        Constants.General.time_toast_important_error,
                                        response.error_message)

                                selectedOrder = undefined
                                return
                            }
                            else if (response.result && response.result.uuid)
                            {
                                selectedOrder = undefined
                                _fromValue.text = "0"

                                // Make sure there is information
                                _confirmSwapModal.close()

                                toast.show(qsTr("Placed the order"), Constants.General.time_toast_basic_info,
                                        Constants.General.prettifyJSON(response.result), false)

                                Constants.General.prevent_coin_disabling.restart()
                            }
                        }
                    }
                }

                // Send button error icon
                DefaultAlertIcon
                {
                    id: _swapAlert

                    function getAlert()
                    {
                        var left_ticker = Constants.API.app.trading_pg.market_pairs_mdl.left_selected_coin
                        var right_ticker = Constants.API.app.trading_pg.market_pairs_mdl.right_selected_coin
                        var right_parent = Constants.API.app.portfolio_pg.global_cfg_mdl.get_parent_coin(right_ticker)
                        var left_parent = Constants.API.app.portfolio_pg.global_cfg_mdl.get_parent_coin(left_ticker)
                        var last_trading_error = Constants.API.app.trading_pg.last_trading_error
                        var fees_error = Constants.API.app.trading_pg.fees.error

                        if (_fromValue.text === "" || parseFloat(_fromValue.text) === 0)
                            return qsTr("Entered amount must be superior than 0.")
                        if (typeof selectedOrder === 'undefined')
                            return qsTr("You must select an order.")
                        if (last_trading_error == TradingError.VolumeIsLowerThanTheMinimum)
                            return qsTr("Entered amount is below the minimum required by this order: %1").arg(selectedOrder.base_min_volume)
                        if (last_trading_error == TradingError.LeftParentChainNotEnabled)
                            return qsTr("%1 needs to be enabled in order to use %2").arg(Constants.API.app.portfolio_pg.global_cfg_mdl.get_parent_coin(left_ticker)).arg(left_ticker)
                        if (last_trading_error == TradingError.LeftParentChainNotEnoughBalance)
                            return qsTr("%1 balance needs to be funded, a non-zero balance is required to pay the gas of %2 transactions").arg(left_parent).arg(left_ticker)
                        if (last_trading_error == TradingError.RightParentChainNotEnabled)
                            return qsTr("%1 needs to be enabled in order to use %2").arg(Constants.API.app.portfolio_pg.global_cfg_mdl.get_parent_coin(right_ticker)).arg(right_ticker)
                        if (last_trading_error == TradingError.RightParentChainNotEnoughBalance)
                            return qsTr("%1 balance needs to be funded, a non-zero balance is required to pay the gas of %2 transactions").arg(right_parent).arg(right_ticker)
                        if (fees_error) {
                            let coin = right_ticker
                            if (fees_error.search(Constants.API.app.portfolio_pg.global_cfg_mdl.get_parent_coin(left_ticker)) > -1) {
                                coin = left_ticker
                            }
                            return qsTr("%1 balance does not have enough funds to pay the gas of %2 transactions").arg(Constants.API.app.portfolio_pg.global_cfg_mdl.get_parent_coin(coin)).arg(coin)
                        }
                        return ""
                    }

                    tooltipText: _swapAlert.getAlert()
                    visible: tooltipText !== ""
                }
            }
        }

        Item
        {
            height: 35
            width: 150
            visible: coinSelectorSimplified.visible

            SearchField
            {
                id: _coinSearchField
                height: 35
                anchors.fill: parent
                anchors.leftMargin: 20
                forceFocus: true
                textField.onTextChanged: _coinList.model.setFilterFixedString(textField.text)
                Component.onDestruction: _coinList.model.setFilterFixedString("")
            }
        }

        Item
        {
            id: coinSelectorSimplified
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            height: 300
            visible: _tradeCard.coinSelection && has_coins_with_balance

            SubCoinSelector
            {
                id: _coinList
                anchors.fill: parent
                anchors.topMargin: 10
                onTickerSelected:
                {
                    _tradeCard.selectedTicker = ticker
                    _tradeCard.coinSelection = false
                    _fromValue.forceActiveFocus()
                }
            }

            Connections {
                target: _tradeCard
                function onCoinSelectionChanged() {
                    _coinSearchField.textField.text = ""
                }
            }
        }

        Item
        {
            height: 45
            width: 150
            visible: bestOrderSimplified.visible && (_bestOrderList.count > 0 || _bestOrderSearchField.textField.text != "")

            SearchField
            {
                id: _bestOrderSearchField
                anchors.topMargin: 10
                height: 35
                anchors.fill: parent
                anchors.leftMargin: 20
                forceFocus: true
                textField.onTextChanged: Constants.API.app.trading_pg.orderbook.best_orders.proxy_mdl.setFilterFixedString(textField.text)
                Component.onDestruction: Constants.API.app.trading_pg.orderbook.best_orders.proxy_mdl.setFilterFixedString("")
            }
        }

        Item
        {
            id: bestOrderSimplified
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            height: 300
            visible: _tradeCard.best && has_coins_with_balance

            SubBestOrder
            {
                id: _bestOrderList
                tradeCard: _tradeCard
                anchors.fill: parent
                anchors.topMargin: 10
                visible: _tradeCard.width == 600

                onSelectedOrderChanged:
                {
                    _tradeCard.selectedOrder = selectedOrder
                    _bestOrderSearchField.textField.text = ""
                    _fromValue.forceActiveFocus()
                }

                onBestChanged:
                {
                    if(!best)
                    {
                        _tradeCard.best = false
                    }
                }
            }

            Connections {
                target: _tradeCard
                function onBestChanged() {
                    _bestOrderSearchField.textField.text = ""
                }
            }

            DefaultBusyIndicator
            {
                id: bestOrdersLoading
                width: 200
                height: 200
                visible: Constants.API.app.trading_pg.orderbook.best_orders_busy
                running: visible
                anchors.centerIn: parent
            }

            DexLabel
            {
                visible: _bestOrderList.count === 0 && !bestOrdersLoading.visible

                anchors.centerIn: parent
                text: qsTr("No buy orders found for %1.").arg(selectedTicker)
                font.pixelSize: Style.textSize2

                DexLabel
                {
                    anchors.top: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("You can check later or try to sell a different coin.")
                }
            }
        }

        Item // Fees Info - Details
        {
            id: _feesCard
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: 350
            height: 50

            enabled: !_swapAlert.visible
            visible: _tradeCard.selectedOrder !== undefined
                    && parseFloat(_fromValue.text) > 0
                    && !bestOrderSimplified.visible
                    && !coinSelectorSimplified.visible
                    && has_coins_with_balance
                    && !_swapAlert.visible

            DexRectangle {
                radius: 25
                anchors.fill: parent
            }

            DefaultText
            {
                anchors.centerIn: parent
                text: qsTr("Calculating fee estimate... ")
                font.pixelSize: Constants.Style.textSizeSmall3
                visible: fees_busy.visible
            }

            DefaultListView
            {
                id: _feesList
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                visible: {
                    return !Constants.API.app.trading_pg.preimage_rpc_busy
                }

                enabled: parent.enabled
                model: Constants.API.app.trading_pg.fees.total_fees

                delegate: RowLayout
                {
                    width: _feesCard.width
                    Component.onCompleted: _feesCard.height += 10
                    Component.onDestruction: _feesCard.height -= 10

                    DefaultText
                    {
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 10
                        text: qsTr("Total %1 fees: ").arg(modelData.coin)
                        font.pixelSize: Constants.Style.textSizeSmall3
                    }

                    DefaultText
                    {
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 10
                        text: qsTr("%2 (%3)")
                                .arg(parseFloat(modelData.required_balance).toFixed(8) / 1)
                                .arg(Constants.General.getFiatText(modelData.required_balance, modelData.coin, false))
                        font.pixelSize: Constants.Style.textSizeSmall3
                            
                    }
                }
            }

            DefaultBusyIndicator
            {
                id: fees_busy
                width: 30
                height: 30
                anchors.centerIn: parent
                visible: Constants.API.app.trading_pg.preimage_rpc_busy || _feesList.count == 0
            }
        }
    }

    Row
    {
        anchors.rightMargin: 15
        anchors.right: parent.right
        height: 50
        spacing: 5
        y: 12
        visible: has_coins_with_balance

        DexAppButton
        {
            visible: _tradeCard.best
            iconSource: Qaterial.Icons.refresh
            iconSize: 14
            opacity: enabled ? containsMouse ? .7 : 1 : .4
            anchors.verticalCenter: parent.verticalCenter
            enabled: !Constants.API.app.trading_pg.orderbook.best_orders_busy
            width: 35
            height: 25
            onClicked:
            {
                Constants.API.app.trading_pg.orderbook.refresh_best_orders()
            }
        }

        DexAppButton
        {
            visible: _tradeCard.best || _tradeCard.coinSelection
            iconSource: Qaterial.Icons.close
            iconSize: 14
            opacity: containsMouse ? .9 : 1
            anchors.verticalCenter: parent.verticalCenter
            width: 35
            height: 25

            onClicked:
            {
                _tradeCard.best = false
                _tradeCard.coinSelection = false
            }
        }
    }
}
