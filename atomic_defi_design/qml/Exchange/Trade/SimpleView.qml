import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import AtomicDEX.TradingError 1.0

import "../../Components"
import "../../Constants"

ColumnLayout
{
    property string selectedTicker: left_ticker
    property var    selectedOrder

    id: root
    anchors.centerIn: parent
    onSelectedTickerChanged: { selectedOrder = undefined; setPair(true, selectedTicker); _fromValue.text = "" }
    onSelectedOrderChanged:  
    {
        if (typeof selectedOrder !== 'undefined') API.app.trading_pg.orderbook.select_best_order(selectedOrder.uuid) 
        else API.app.trading_pg.reset_order()

        if (parseFloat(_fromValue.text) > parseFloat(API.app.trading_pg.max_volume))
            _fromValue.text = API.app.trading_pg.max_volume
        API.app.trading_pg.determine_fees()
    }
    onEnabledChanged: selectedOrder = undefined
    Component.onDestruction: selectedOrder = undefined

    DefaultRectangle
    {
        id: swap_card
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 380
        Layout.preferredHeight: _unitPrice.visible ? 410 : 380
        radius: 20

        MouseArea
        {
            anchors.fill: parent
            onPressed: _fromValue.focus = false
        }

        ColumnLayout // Header
        {
            id: swap_card_desc

            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 20
            width: parent.width

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

        Qaterial.FlatButton // History Button
        {
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 15

            icon.source: Qaterial.Icons.bookOpenPageVariant
            height: 50
            width: 50

            ToolTip.delay: 800
            ToolTip.visible: hovered
            ToolTip.text: qsTr("History.")
        }

        HorizontalLine
        {
            anchors.top: swap_card_desc.bottom
            anchors.topMargin: 20
            width: swap_card.width
        }

        ColumnLayout // Content
        {
            anchors.top: swap_card_desc.bottom
            anchors.topMargin: 40
            anchors.left: parent.left
            anchors.horizontalCenter: parent.horizontalCenter
            
            DefaultRectangle // From
            {
                id: swap_from_card
                Layout.preferredWidth: swap_card.width - 20
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
                    width: Math.min(_maxWidth, _textMetrics.boundingRect.width)
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
                        else if (parseFloat(text) < parseFloat(API.app.trading_pg.min_trade_vol))
                            return
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
                        onSelectedTickerChanged: root.selectedTicker = selectedTicker
                        id: coinsListModalLoader
                        sourceComponent: coinsListModal
                    }

                    Connections
                    {
                        target: coinsListModalLoader
                        function onLoaded() { coinsListModalLoader.item.selectedTickerChanged.connect(function() { root.selectedTicker = coinsListModalLoader.item.selectedTicker }) }
                    }
                }
            }

            // To
            DefaultRectangle
            {
                Layout.preferredWidth: swap_card.width - 20
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
                    enabled: false
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 23
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    text: parseFloat(_fromValue.text) >= API.app.trading_pg.min_trade_vol ? API.app.trading_pg.total_amount : "0"
                    font.pixelSize: Style.textSizeSmall5
                    Component.onCompleted: color = _fromValue.placeholderTextColor
                }

                Text    // Amount In Fiat
                {
                    enabled: _toValue.text
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
                        sourceComponent: bestOrdersModal
                    }
                    
                    Connections
                    {
                        target: _bestOrdersModalLoader
                        function onLoaded() 
                        { 
                            _bestOrdersModalLoader.item.currentLeftToken = selectedTicker
                            _bestOrdersModalLoader.item.selectedOrderChanged.connect(function() 
                            {
                                root.selectedOrder = _bestOrdersModalLoader.item.selectedOrder
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
                Layout.preferredWidth: swap_card.width - 30
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
                }

                Image // Alert
                {
                    id: _swapAlert

                    function getAlert()
                    {
                        if (typeof selectedOrder === 'undefined')
                            return qsTr("You must select an order.")
                        
                        if (_fromValue.text === "")
                            return qsTr("You must enter an amount")
                        let fromValue = parseFloat(_fromValue.text)
                        if (fromValue === 0)
                            return qsTr("Entered amount must be superior than 0.")
                        if (API.app.trading_pg.last_trading_error === TradingError.VolumeIsLowerThanTheMinimum)
                            return qsTr("Entered amount is below the minimum required by this order: %1").arg(parseFloat(selectedOrder.base_min_volume))
                        
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
    }

    DefaultRectangle // Swap Info - Details
    {
        id: _feesCard
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 350
        Layout.preferredHeight: 60

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

    // Coins list
    Component
    {
        id: coinsListModal
        BasicModal
        {
            property string selectedTicker

            id: root
            width: 450
            ModalContent
            {
                title: qsTr("Select a ticker")
                RowLayout
                {
                    Layout.fillWidth: true
                    TextField
                    {
                        id: searchName
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter
                        placeholderText: "Search a name"
                        font.pixelSize: Style.textSize1
                        background: Rectangle
                        {
                            color: theme.backgroundColor
                            border.width: 1
                            border.color: theme.colorRectangleBorderGradient1
                            radius: 10
                        }
                        onTextChanged:
                        {
                            if (text.length > 30)
                                text = text.substring(0, 30)
                            API.app.trading_pg.market_pairs_mdl.left_selection_box.search_exp = text
                        }

                        Component.onDestruction: API.app.trading_pg.market_pairs_mdl.left_selection_box.search_exp = ""
                    }
                }

                RowLayout
                {
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    DefaultText { text: qsTr("Token name") }
                }

                ColumnLayout
                {
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    DefaultListView
                    {
                        Layout.fillWidth: true
                        model: API.app.trading_pg.market_pairs_mdl.left_selection_box
                        spacing: 20
                        delegate: ItemDelegate
                        {
                            width: root.width
                            anchors.horizontalCenter: root.horizontalCenter
                            height: 40

                            DefaultImage
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 5
                                anchors.left: parent.left
                                width: 30
                                height: 30
                                source: General.coinIcon(model.ticker)
                                DefaultText
                                {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.right
                                    anchors.leftMargin: 20
                                    text: model.ticker
                                }
                            }

                            DefaultText // Balance
                            {

                            }

                            MouseArea 
                            {
                                anchors.fill: parent
                                onClicked: 
                                {
                                    root.selectedTicker = model.ticker
                                    close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Best orders list
    Component 
    {
        id: bestOrdersModal
        BasicModal 
        {
            property var    selectedOrder
            property string currentLeftToken // The token we wanna sell

            property int    _rowWidth: width - 20
            property int    _rowHeight: 50
            property int    _tokenColumnSize: 60
            property int    _quantityColumnSize: 100
            property int    _quantityInBaseColumnSize: 100
            property int    _fiatVolumeColumnSize: 50
            property int    _cexRateColumnSize: 50
            
            onOpened: API.app.trading_pg.orderbook.refresh_best_orders()
            id: root
            width: 800
            ModalContent 
            {
                title: qsTr("Best Orders")
                DefaultListView
                {
                    Layout.preferredHeight: 450
                    Layout.fillWidth: true
                    model: API.app.trading_pg.orderbook.best_orders.proxy_mdl
                    header: Item // Best orders list header
                    {
                        width: _rowWidth
                        height: _rowHeight
                        RowLayout                   // Order Columns Name
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.fill: parent
                            DefaultText             // "Token" Header
                            {
                                Layout.preferredWidth: _tokenColumnSize
                                text: qsTr("Token")
                                font.family: Style.font_family
                                font.bold: true
                                font.weight: Font.Black
                            }
                            DefaultText             // "Available Quantity" Header
                            {
                                Layout.preferredWidth: _quantityColumnSize
                                text: qsTr("Available Quantity")
                                font.family: Style.font_family
                                font.bold: true
                                font.weight: Font.Black
                            }
                            DefaultText             // "Available Quantity (in BASE)" header
                            {
                                Layout.preferredWidth: _quantityInBaseColumnSize
                                text: qsTr("Available Quantity (in %1)").arg(currentLeftToken)
                                font.family: Style.font_family
                                font.bold: true
                                font.weight: Font.Black
                            }
                            DefaultText             // "Fiat Volume" column header
                            {
                                Layout.preferredWidth: _fiatVolumeColumnSize
                                text: qsTr("Fiat Volume")
                                font.family: Style.font_family
                                font.bold: true
                                font.weight: Font.Black
                            }
                            DefaultText             // "CEX Rate" column header
                            {
                                Layout.preferredWidth: _cexRateColumnSize
                                text: qsTr("CEX Rate")
                                font.family: Style.font_family
                                font.bold: true
                                font.weight: Font.Black
                            }
                        }
                    }
                    delegate: ItemDelegate // Order Line
                    {
                        width: _rowWidth
                        height: _rowHeight
                        HorizontalLine { width: parent.width }
                        RowLayout                   // Order Info
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.fill: parent
                            RowLayout                           // Order Token
                            {
                                property int _iconWidth: 24

                                Layout.preferredWidth: _tokenColumnSize
                                DefaultImage                         // Order Token Icon
                                {
                                    Layout.preferredWidth: parent._iconWidth
                                    Layout.preferredHeight: 24
                                    source: General.coinIcon(coin)
                                }
                                DefaultText                          // Order Token Name
                                {
                                    id: _tokenName
                                    Layout.preferredWidth: _tokenColumnSize - parent._iconWidth
                                    text: coin
                                    font.pixelSize: 14
                                }
                            }
                            VerticalLine { Layout.preferredHeight: parent.parent.height }
                            DefaultText                         // Order Available Quantity
                            {
                                Layout.preferredWidth: _quantityColumnSize
                                text: parseFloat(General.formatDouble(quantity, General.amountPrecision, true)).toFixed(8)
                                font.pixelSize: 14
                            }
                            VerticalLine { Layout.preferredHeight: parent.parent.height }
                            DefaultText                         // Order Available Quantity In BASE
                            {
                                Layout.preferredWidth: _quantityInBaseColumnSize
                                text: parseFloat(General.formatDouble(base_max_volume, General.amountPrecision, true)).toFixed(8)
                                font.pixelSize: 14
                            }
                            VerticalLine { Layout.preferredHeight: parent.parent.height }
                            DefaultText                         // Order Fiat Volume
                            {
                                Layout.preferredWidth: _fiatVolumeColumnSize
                                text: price_fiat+API.app.settings_pg.current_fiat_sign
                            }
                            VerticalLine { Layout.preferredHeight: parent.parent.height }
                            DefaultText
                            {
                                Layout.preferredWidth: _cexRateColumnSize
                                text: cex_rates=== "0" ? "N/A" : parseFloat(cex_rates)>0? "+"+parseFloat(cex_rates).toFixed(2)+"%" : parseFloat(cex_rates).toFixed(2)+"%"
                            }
                            DefaultTooltip 
                            {
                                id: _tooltip
                                dim: true
                                modal: true
                                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                                width: 250
                                contentItem: DexLabelUnlinked 
                                {
                                    text_value: qsTr(" %1 is not enabled - Do you want to enable it to be able to select %2 best orders ?<br><a href='#'>Yes</a> - <a href='#no'>No</a>").arg(coin).arg(coin)
                                    wrapMode: DefaultText.Wrap
                                    width: 250
                                    onLinkActivated: 
                                    {
                                        if (link==="#no") _tooltip.close()
                                        else 
                                        {
                                            if (API.app.enable_coins([coin]) === true) _tooltip.close()
                                            else cannot_enable_coin_modal.open()
                                        }
                                    }
                                    ModalLoader 
                                    {
                                        property string coin_to_enable_ticker: coin
                                        id: cannot_enable_coin_modal
                                        sourceComponent: CannotEnableCoinModal { coin_to_enable_ticker: cannot_enable_coin_modal.coin_to_enable_ticker }
                                    }
                                }
                                delay: 200
                            }
                        }
                        onClicked: 
                        {
                            if (!API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled) _tooltip.open()
                            else selectedOrder = { "coin": coin, "uuid": uuid, "price": price, "base_min_volume": base_min_volume, "base_max_volume": base_max_volume }
                        }
                    }
                }
            }
        }
    }

    // Current Orders Modal
    Component
    {
        BasicModal
        {
            id: ordersModal
        }
    }
}
