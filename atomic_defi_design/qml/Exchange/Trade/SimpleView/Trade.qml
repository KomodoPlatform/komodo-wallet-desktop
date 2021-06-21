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
import "../../../Constants"
import "../"

ClipRRect // Trade Card
{
    property string selectedTicker: left_ticker
    property var    selectedOrder:  undefined
    property bool   best: false
    property bool   coinSelection: false

    onSelectedTickerChanged: { selectedOrder = undefined; setPair(true, selectedTicker); _fromValue.field.text = "" }
    onSelectedOrderChanged:
    {
        if (typeof selectedOrder !== 'undefined' && selectedOrder.from_best_order) API.app.trading_pg.orderbook.select_best_order(selectedOrder.uuid)
        else if (typeof selectedOrder !== 'undefined') API.app.trading_pg.preffered_order = selectedOrder
        else API.app.trading_pg.reset_order()

        API.app.trading_pg.determine_fees()
    }
    onEnabledChanged: selectedOrder = undefined
    Component.onDestruction: selectedOrder = undefined
    onBestChanged: if (best) API.app.trading_pg.orderbook.refresh_best_orders()

    id: _tradeCard
    width: bestOrderSimplified.visible ? 600 : coinSelection? 450 : 380
    height: col.height+15
    radius: 20

    Connections // Catches C++ `trading_page` class signals.
    {
        enabled: parent.enabled
        target: API.app.trading_pg
        
        function onSelectedOrderStatusChanged() // When the selected order status has changed.
        {
            if (API.app.trading_pg.selected_order_status == SelectedOrderStatus.OrderNotExistingAnymore)
            {
                _orderDisappearModalLoader.open()
                _confirmSwapModal.close()
            }
        }

        function onPreferredOrderChangeFinished()   // When selected order has changed
        {
            if (typeof selectedOrder === 'undefined')
                return
            if (parseFloat(_fromValue.field.text) > API.app.trading_pg.max_volume)
                _fromValue.field.text = API.app.trading_pg.max_volume
        }

        function onVolumeChanged()
        {
            _fromValue.field.text = API.app.trading_pg.volume
        }
    }

    Connections
    {
        target: API.app.trading_pg.orderbook.bids

        function onBetterOrderDetected(newOrder)
        {
            // We shoould rename SelectedOrderStatus enum to OrderbookNotification.
            if (API.app.trading_pg.selected_order_status == SelectedOrderStatus.BetterPriceAvailable)
            {
                // Price changed and we can still afford the volume.
                if (parseFloat(newOrder.base_max_volume) <= selectedOrder.base_max_volume && parseFloat(newOrder.rel_max_volume) >= API.app.trading_pg.total_amount)
                {
                    console.log("Updating forms with better price");
                    Qaterial.SnackbarManager.show(
                    {
                        expandable: true,
                        text: qsTr("Better price found: %1. Updating forms.")
                                    .arg(parseFloat(newOrder.price).toFixed(8)),
                        timeout: Qaterial.Style.snackbar.longDisplayTime
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
                                    .arg(API.app.trading_pg.total_amount),
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
        id: col
        width: parent.width
        spacing: 10
        Column // Header
        {
            id: _swapCardHeader

            width: parent.width-20
            padding: 10
            anchors.horizontalCenter: parent.horizontalCenter

            DefaultText // Title
            {
                text: qsTr("Swap")
                font.pixelSize: Style.textSize1
            }

            DefaultText // Description
            {
                anchors.topMargin: 12
                font.pixelSize: Style.textSizeSmall4
                text: qsTr("Instant trading with best orders")

                Qaterial.OutlineButton // Reset Form Button
                {
                    enabled: !best && typeof selectedOrder !== 'undefined'
                    visible: enabled
                    width: 50
                    height: 50
                    anchors.left: parent.right
                    anchors.leftMargin: 100
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -8

                    outlined: false

                    Qaterial.ColorIcon
                    {
                        anchors.centerIn: parent
                        source:  Qaterial.Icons.broom
                        color: theme.buttonColorTextEnabled
                        opacity: .8
                    }

                    onClicked: selectedOrder = undefined

                    hoverEnabled: true

                    ToolTip.delay: 500
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Reset form.")
                }
            }
        }

        HorizontalLine
        {
            width: _tradeCard.width
        }

        ColumnLayout // Content
        {
            width: parent.width
            
            anchors.horizontalCenter: parent.horizontalCenter

            DefaultRectangle // From
            {
                id: swap_from_card
                Layout.preferredWidth: _tradeCard.width - 20
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignHCenter
                radius: 20
                visible: !coinSelectorSimplified.visible

                DefaultText // From Text
                {
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    anchors.left: parent.left
                    anchors.leftMargin: 17
                    text: qsTr("From")
                    font.pixelSize: Style.textSizeSmall4
                }

                Text // Tradable Balance
                {
                    readonly property int _maxWidth: 140

                    id: _fromBalance
                    width: Math.min(_maxWidth, _textMetrics.boundingRect.width + 10)
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 17
                    text: qsTr("%1").arg(API.app.trading_pg.max_volume)
                    font.pixelSize: Style.textSizeSmall2
                    elide: Text.ElideRight
                    color: Style.colorWhite1

                    DexImage
                    {
                        id: _fromBalanceIcon
                        width: 16
                        height: 16
                        anchors.right: parent.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        source: General.image_path + "menu-assets-white.svg"
                        opacity: .6
                    }

                    MouseArea
                    {
                        anchors.left: _fromBalanceIcon.left
                        anchors.right: _fromBalance.right
                        anchors.top: _fromBalance.top
                        anchors.bottom: _fromBalance.bottom
                        hoverEnabled: true
                        ToolTip
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
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    field.placeholderText: typeof selectedOrder !== 'undefined' ? qsTr("Minimum: %1").arg(API.app.trading_pg.min_trade_vol) : qsTr("Enter an amount")
                    field.font.pixelSize: Style.textSizeSmall5
                    field.background: Rectangle { color: theme.backgroundColor }
                    field.onTextChanged:
                    {
                        if (field.text === "")
                        {
                            API.app.trading_pg.volume = 0
                            field.text = ""
                        }
                        else
                            API.app.trading_pg.volume = field.text
                        API.app.trading_pg.determine_fees()
                        API.app.trading_pg.orderbook.refresh_best_orders()
                    }
                    field.onFocusChanged:
                    {
                        if (!focus && parseFloat(field.text) < parseFloat(API.app.trading_pg.min_trade_vol))
                        {
                            field.text = API.app.trading_pg.min_trade_vol
                        }
                    }
                    Component.onCompleted: field.text = ""
                }

                Text    // Amount In Fiat
                {
                    enabled: _fromValue.field.text
                    anchors.top: _fromValue.bottom
                    anchors.topMargin: -3
                    anchors.left: _fromValue.left
                    anchors.leftMargin: 24
                    font.pixelSize: Style.textSizeSmall1
                    color: theme.buttonColorTextDisabled
                    text: enabled ? General.getFiatText(_fromValue.field.text, selectedTicker) : ""
                }

                Rectangle // Select ticker button
                {
                    id: _selectTickerBut
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    width: _selectedTickerIcon.width + _selectedTickerText.width + _selectedTickerArrow.width + 29.5
                    height: 30
                    radius: 10
                    border.width: 0
                    color: _selectedTickerMouseArea.containsMouse ? "#8b95ed" : theme.backgroundColor

                    DefaultMouseArea
                    {
                        id: _selectedTickerMouseArea
                        anchors.fill: parent
                        onClicked: {
                            _tradeCard.coinSelection = true
                            _tradeCard.best = false
                            //coinsListModalLoader.open()
                        }
                        hoverEnabled: true
                    }

                    DefaultImage
                    {
                        id: _selectedTickerIcon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        width: 20
                        height: 20
                        source: General.coinIcon(selectedTicker)
                        DefaultText
                        {
                            id: _selectedTickerText
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right
                            anchors.leftMargin: 10
                            text: selectedTicker
                            font.pixelSize: Style.textSizeSmall4

                            Arrow
                            {
                                id: _selectedTickerArrow
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: 5
                                up: false
                            }
                        }
                    }

                    ModalLoader
                    {
                        property string selectedTicker
                        onSelectedTickerChanged: _tradeCard.selectedTicker = selectedTicker
                        id: coinsListModalLoader
                        sourceComponent: CoinsListModal {}
                    }

                    Connections
                    {
                        target: coinsListModalLoader
                        function onLoaded() { coinsListModalLoader.item.selectedTickerChanged.connect(function() { _tradeCard.selectedTicker = coinsListModalLoader.item.selectedTicker }) }
                    }
                }

                DexRectangle // MAX Button
                {
                    anchors.right: _selectTickerBut.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: _selectTickerBut.verticalCenter
                    border.width: 0

                    width: 40
                    height: 20

                    DefaultMouseArea
                    {
                        id: _maxButMouseArea
                        anchors.fill: parent
                        onClicked: _fromValue.field.text = API.app.trading_pg.max_volume
                        hoverEnabled: true
                    }

                    DexLabel
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        color: _maxButMouseArea.containsMouse ? 
                                    _maxButMouseArea.pressed ? "#173948" : "#204c61"
                               : theme.accentColor
                        anchors.fill: parent
                        text: qsTr("MAX")
                    }
                }
            }

            DefaultRectangle // To
            {
                Layout.preferredWidth: _tradeCard.width - 20
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 15
                radius: 20
                visible: !bestOrderSimplified.visible && !coinSelectorSimplified.visible

                DefaultText
                {
                    anchors.fill: parent
                    anchors.leftMargin: 17
                    anchors.topMargin: 14
                    text: qsTr("To")
                    font.pixelSize: Style.textSizeSmall4
                }

                AmountField // Amount
                {
                    id: _toValue
                    enabled: false
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    field.text: API.app.trading_pg.total_amount
                    field.font.pixelSize: Style.textSizeSmall5
                    field.color: theme.buttonColorTextDisabled
                    field.background: Rectangle { color: theme.backgroundColor }
                }

                Text    // Amount In Fiat
                {
                    enabled: parseFloat(_toValue.field.text) > 0
                    anchors.top: _toValue.bottom
                    anchors.topMargin: -3
                    anchors.left: _toValue.left
                    anchors.leftMargin: 24
                    font.pixelSize: Style.textSizeSmall1
                    color: theme.buttonColorTextDisabled
                    text: enabled ? General.getFiatText(_toValue.field.text, _tradeCard.selectedOrder.coin?? "") : ""
                }

                Rectangle // Shows best order coin
                {
                    id: _selectBestOrderButton
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    width: _feesCard.visible ? _bestOrderIcon.width + _bestOrderTickerText.implicitWidth + _bestOrderArrow.width + 29.5 : _piclOrderLabel.implicitWidth+20
                    height: 30
                    radius: 10
                    border.width: 0
                    color: _bestOrdersMouseArea.containsMouse ? "#8b95ed" : theme.backgroundColor
                    opacity: _bestOrdersMouseArea.enabled ? 1 : 0.3

                    DefaultMouseArea
                    {
                        id: _bestOrdersMouseArea
                        anchors.fill: parent
                        onClicked: _tradeCard.best = true
                        hoverEnabled: true
                        enabled: parseFloat(_fromValue.field.text) > 0
                    }

                    DefaultImage // Button with icon (a best order is currently selected)
                    {
                        id: _bestOrderIcon
                        enabled: typeof selectedOrder !== 'undefined'
                        source: enabled ? General.coinIcon(selectedOrder.coin) : ""
                        visible: enabled
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        width: 20
                        height: 20
                        DefaultText
                        {
                            id: _bestOrderTickerText
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right
                            anchors.leftMargin: 10
                            text: enabled ? selectedOrder.coin : ""
                            font.pixelSize: Style.textSizeSmall4
                            Arrow
                            {
                                id: _bestOrderArrow
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: 5
                                up: false
                            }
                        }
                    }

                    DefaultText  // Button (no order is currently selected)
                    {
                        id:_piclOrderLabel
                        enabled: !_bestOrderIcon.enabled
                        visible: enabled
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        text: qsTr("Pick an order")
                        font.pixelSize: Style.textSizeSmall4
                        Arrow
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right
                            anchors.leftMargin: 5
                            up: false
                        }
                    }

                    ModalLoader
                    {
                        id: _bestOrdersModalLoader
                        sourceComponent: BestOrdersModal {}
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
                visible: enabled && !bestOrderSimplified.visible && !coinSelectorSimplified.visible

                DefaultText
                {
                    Layout.rightMargin: 120
                    font.pixelSize: Style.textSizeSmall3
                    text: qsTr("Price")
                }
                DefaultText
                {
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: Style.textSizeSmall3
                    text: selectedOrder ? "1 %1 = %2 %3"
                                            .arg(atomic_qt_utilities.retrieve_main_ticker(selectedTicker))
                                            .arg(parseFloat(API.app.trading_pg.price).toFixed(8))
                                            .arg(atomic_qt_utilities.retrieve_main_ticker(selectedOrder.coin))
                                        : ""
                }
            }

            Item
            {
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: _tradeCard.width - 30
                Layout.preferredHeight: 40
                visible: !bestOrderSimplified.visible && !coinSelectorSimplified.visible

                DefaultButton
                {
                    enabled: !API.app.trading_pg.preimage_rpc_busy && !_swapAlert.visible

                    anchors.fill: parent
                    text: qsTr("Swap Now")
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

                            const response = General.clone(buy_sell_last_rpc_data)

                            if (response.error_code)
                            {
                                _confirmSwapModal.close()

                                toast.show(qsTr("Failed to place the order"),
                                        General.time_toast_important_error,
                                        response.error_message)

                                selectedOrder = undefined
                                return
                            }
                            else if (response.result && response.result.uuid)
                            {
                                selectedOrder = undefined
                                _fromValue.field.text = "0"

                                // Make sure there is information
                                _confirmSwapModal.close()

                                toast.show(qsTr("Placed the order"), General.time_toast_basic_info,
                                        General.prettifyJSON(response.result), false)

                                General.prevent_coin_disabling.restart()
                            }
                        }
                    }
                }

                Image // Alert
                {
                    id: _swapAlert

                    function getAlert()
                    {
                        if (_fromValue.field.text === "" || parseFloat(_fromValue.field.text) === 0)
                            return qsTr("Entered amount must be superior than 0.")
                        if (typeof selectedOrder === 'undefined')
                            return qsTr("You must select an order.")
                        if (API.app.trading_pg.last_trading_error == TradingError.VolumeIsLowerThanTheMinimum)
                            return qsTr("Entered amount is below the minimum required by this order: %1").arg(selectedOrder.base_min_volume)
                        if (API.app.trading_pg.last_trading_error == TradingError.LeftParentChainNotEnabled)
                            return qsTr("Parent chain of left ticker is not enabled.")
                        if (API.app.trading_pg.last_trading_error == TradingError.LeftParentChainNotEnoughBalance)
                            return qsTr("Left ticker parent chain balance needs to be funded")
                        if (API.app.trading_pg.last_trading_error == TradingError.RightParentChainNotEnabled)
                            return qsTr("Parent chain of right ticker is not enabled.")
                        if (API.app.trading_pg.last_trading_error == TradingError.RightParentChainNotEnoughBalance)
                            return qsTr("Right ticker parent chain balance needs to be funded")

                        return ""
                    }

                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    visible: ToolTip.text !== ""

                    source: Qaterial.Icons.alert

                    ToolTip.visible: _alertMouseArea.containsMouse
                    ToolTip.text: getAlert()

                    DefaultColorOverlay
                    {
                        anchors.fill: parent
                        source: parent
                        color: "yellow"
                    }
                    MouseArea
                    {
                        id: _alertMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
        Item 
        {
            id: coinSelectorSimplified
            width: parent.width
            height: 300
            visible: _tradeCard.coinSelection 
            Item 
            {
                width: parent.width
                height: 50
                Qaterial.ColorIcon 
                {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qaterial.Icons.magnify
                    x: 25 
                    opacity: .7
                }
                DexTextField 
                {
                    id: _coinSearchField
                    width: parent.width-70
                    height: parent.height
                    font.pixelSize: 16
                    x: 45
                    placeholderText: qsTr("Search")
                    background: DexRectangle 
                    {
                        border.width: 0
                        color: 'transparent'
                    }
                    onTextChanged: 
                    {
                      _coinList.model.setFilterFixedString(text)
                    }
                }
            }
            SubCoinSelector 
            {
                id: _coinList
                tradeCard: _tradeCard
                onSelectedTickerChanged: {
                    _tradeCard.selectedTicker = selectedTicker
                    _tradeCard.coinSelection = false
                }
                anchors.fill: parent
                anchors.rightMargin: 10
                anchors.leftMargin: 20
                anchors.bottomMargin: 10
                anchors.topMargin: 50
                //visible: _tradeCard.width == 600
            } 

        }
        Item 
        {
            id: bestOrderSimplified
            width: parent.width
            height: 300
            visible: _tradeCard.best 
            Item 
            {
                width: parent.width
                height: 50
                Qaterial.ColorIcon 
                {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qaterial.Icons.magnify
                    x: 25 
                    opacity: .7
                }
                DexTextField 
                {
                    id: _bestOrderSearchField
                    width: parent.width-70
                    height: parent.height
                    font.pixelSize: 16
                    x: 45
                    placeholderText: qsTr("Search")
                    background: DexRectangle 
                    {
                        border.width: 0
                        color: 'transparent'
                    }
                    onTextChanged: 
                    {
                      API.app.trading_pg.orderbook.best_orders.proxy_mdl.setFilterFixedString(text)
                    }
                }
            }
            SubBestOrder 
            {
                id: _bestOrderList
                tradeCard: _tradeCard
                onSelectedOrderChanged: 
                {
                    _tradeCard.selectedOrder = selectedOrder
                    _bestOrderSearchField.text = ""
                }
                onBestChanged: 
                {
                    if(!best) 
                    {
                        _tradeCard.best = false
                    }
                }
                anchors.fill: parent
                anchors.rightMargin: 10
                anchors.leftMargin: 20
                anchors.bottomMargin: 10
                anchors.topMargin: 50
                visible: _tradeCard.width == 600
            } 
            BusyIndicator
            {
                width: 200
                height: 200
                visible: API.app.trading_pg.orderbook.best_orders_busy
                running: visible
                anchors.centerIn: parent
            }

        }


        DefaultRectangle // Swap Info - Details
        {
            id: _feesCard
            anchors.horizontalCenter: parent.horizontalCenter
            width: 350
            height: 60

            enabled: !_swapAlert.visible
            visible: enabled & !bestOrderSimplified.visible & !coinSelectorSimplified.visible

            radius: 25

            DefaultBusyIndicator
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: API.app.trading_pg.preimage_rpc_busy
            }

            DefaultListView
            {
                id: _feesList
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                visible: !API.app.trading_pg.preimage_rpc_busy
                enabled: parent.enabled
                model: API.app.trading_pg.fees.total_fees
                delegate: RowLayout
                {
                    width: _feesCard.width
                    Component.onCompleted: _feesCard.height += 20
                    Component.onDestruction: _feesCard.height -= 20

                    DefaultText
                    {
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 10
                        text: qsTr("Total %1 fees: ").arg(modelData.coin)
                        font.pixelSize: Style.textSizeSmall3
                    }
                    DefaultText
                    {
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 10
                        text: qsTr("%2 (%3)")
                                .arg(parseFloat(modelData.required_balance).toFixed(8) / 1)
                                .arg(General.getFiatText(modelData.required_balance, modelData.coin, false))
                        font.pixelSize: Style.textSizeSmall3
                    }
                }
            }
        }
    }
    Row 
    {
        anchors.rightMargin: 15
        anchors.right: parent.right
        y: 12
        Qaterial.AppBarButton 
        {
            icon.source: Qaterial.Icons.refresh
            visible: _tradeCard.best
            enabled: !API.app.trading_pg.orderbook.best_orders_busy
            onClicked: 
            {
                API.app.trading_pg.orderbook.refresh_best_orders()
            }
        }
        Qaterial.AppBarButton 
        {
            icon.source: Qaterial.Icons.close
            visible: _tradeCard.best || _tradeCard.coinSelection
            onClicked: 
            {
                _tradeCard.best = false
                _tradeCard.coinSelection = false
            }
        }
    }
}
