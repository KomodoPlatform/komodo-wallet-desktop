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

    onSelectedTickerChanged: { selectedOrder = undefined; setPair(true, selectedTicker); _fromValue.text = "" }
    onSelectedOrderChanged:
    {
        if (typeof selectedOrder !== 'undefined') API.app.trading_pg.orderbook.select_best_order(selectedOrder.uuid)
        else API.app.trading_pg.reset_order()

        API.app.trading_pg.determine_fees()
    }
    onEnabledChanged: selectedOrder = undefined
    Component.onDestruction: selectedOrder = undefined

    id: _tradeCard
    width: 380
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
            if (parseFloat(_fromValue.text) > API.app.trading_pg.max_volume)
                _fromValue.text = API.app.trading_pg.max_volume
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
                    text: qsTr("Tradable: %1").arg(API.app.trading_pg.max_volume)
                    font.pixelSize: Style.textSizeSmall2
                    elide: Text.ElideRight
                    color: Style.colorWhite1

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        ToolTip
                        {
                            visible: parent.containsMouse
                            text: parent.parent.text
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

                TextField // Amount
                {
                    id: _fromValue
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 19
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    placeholderText: typeof selectedOrder !== 'undefined' ? qsTr("Minimum: %1").arg(API.app.trading_pg.min_trade_vol) : qsTr("Enter an amount")
                    font.pixelSize: Style.textSizeSmall5
                    background: Rectangle { color: theme.backgroundColor }
                    validator: RegExpValidator { regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/ }
                    onTextChanged:
                    {
                        if (text === "")
                            API.app.trading_pg.volume = 0
                        else
                        {
                            API.app.trading_pg.volume = text
                            text = API.app.trading_pg.volume
                        }
                        API.app.trading_pg.determine_fees()
                    }
                    onFocusChanged:
                    {
                        if (!focus && parseFloat(text) < parseFloat(API.app.trading_pg.min_trade_vol))
                        {
                            text = API.app.trading_pg.min_trade_vol
                        }
                    }
                }

                Text    // Amount In Fiat
                {
                    enabled: _fromValue.text
                    anchors.top: _fromValue.bottom
                    anchors.left: _fromValue.left
                    anchors.leftMargin: 15
                    font.pixelSize: Style.textSizeSmall1
                    Component.onCompleted: color = _fromValue.placeholderTextColor
                    text: enabled ? General.getFiatText(_fromValue.text, selectedTicker) : ""
                }

                DefaultText
                {
                    color: _fromValue.color
                }

                Rectangle // Select ticker button
                {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
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
                        onClicked: coinsListModalLoader.open()
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
            }

            DefaultRectangle // To
            {
                Layout.preferredWidth: _tradeCard.width - 20
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 15
                radius: 20

                DefaultText
                {
                    anchors.fill: parent
                    anchors.leftMargin: 17
                    anchors.topMargin: 14
                    text: qsTr("To")
                    font.pixelSize: Style.textSizeSmall4
                }

                DefaultText
                {
                    id: _toValue
                    enabled: !_swapAlert.visible
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 23
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    text: enabled ? API.app.trading_pg.total_amount : "0"
                    font.pixelSize: Style.textSizeSmall5
                    Component.onCompleted: color = _fromValue.placeholderTextColor
                }

                Text    // Amount In Fiat
                {
                    enabled: parseFloat(_toValue.text) > 0
                    anchors.top: _toValue.bottom
                    anchors.topMargin: 4
                    anchors.left: _toValue.left
                    anchors.leftMargin: 3
                    font.pixelSize: Style.textSizeSmall1
                    Component.onCompleted: color = _fromValue.placeholderTextColor
                    text: enabled ? General.getFiatText(_toValue.text, selectedOrder.coin) : ""
                }

                DefaultRectangle // Shows best order coin
                {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    width: _bestOrderIcon.enabled ? _bestOrderIcon.width + _bestOrderTickerText.width + _bestOrderArrow.width + 29.5 : 110
                    height: 30
                    radius: 10
                    border.width: 0
                    color: _bestOrdersMouseArea.containsMouse ? "#8b95ed" : theme.backgroundColor
                    opacity: _bestOrdersMouseArea.enabled ? 1 : 0.3

                    DefaultMouseArea
                    {
                        id: _bestOrdersMouseArea
                        anchors.fill: parent
                        onClicked: _bestOrdersModalLoader.open()
                        hoverEnabled: true
                        enabled: parseFloat(_fromValue.text) > 0
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

                    DefaultText  // Button (no bester order is currently selected)
                    {
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

                    Connections
                    {
                        target: _bestOrdersModalLoader
                        function onLoaded()
                        {
                            _bestOrdersModalLoader.item.currentLeftToken = selectedTicker
                            _bestOrdersModalLoader.item.selectedOrderChanged.connect(function()
                            {
                                _tradeCard.selectedOrder = _bestOrdersModalLoader.item.selectedOrder
                                _bestOrdersModalLoader.close()
                            })
                        }
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
                    text: parent.enabled ? "1 %1 = %2 %3"
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

                DefaultButton
                {
                    enabled: !API.app.trading_pg.preimage_rpc_busy && !_swapAlert.visible

                    anchors.fill: parent
                    text: qsTr("Swap Now !")
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
                                _fromValue.text = "0"

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
                        if (_fromValue.text === "" || parseFloat(_fromValue.text) === 0)
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


        DefaultRectangle // Swap Info - Details
        {
            id: _feesCard
            anchors.horizontalCenter: parent.horizontalCenter
            width: 350
            height: 60

            enabled: !_swapAlert.visible
            visible: enabled

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
}
