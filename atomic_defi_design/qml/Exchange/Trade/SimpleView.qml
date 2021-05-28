import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"
import "./BestOrder" as BestOrder

ColumnLayout
{
    property string selectedTicker: left_ticker
    property var    selectedOrder

    id: root
    anchors.centerIn: parent
    onSelectedTickerChanged: { setPair(true, selectedTicker); _fromValue.text = "" }
    onSelectedOrderChanged:  { API.app.trading_pg.orderbook.select_best_order(selectedOrder.uuid) }
    DefaultRectangle
    {
        id: swap_card
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 370
        Layout.preferredHeight: 375
        radius: 20

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
                    anchors.fill: parent
                    anchors.leftMargin: 17
                    anchors.topMargin: 14
                    text: qsTr("From")
                    font.pixelSize: Style.textSizeSmall4
                }

                DefaultText // Balance
                {
                    anchors.right: parent.right
                    anchors.rightMargin: 17
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    text: qsTr("Tradable %1 : %2")
                        .arg('<a href=""></a>')
                        .arg(API.app.trading_pg.max_volume)
                    font.pixelSize: Style.textSizeSmall4
                }

                TextField // Amount
                {
                    id: _fromValue
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    height: 30
                    placeholderText: "0.0"
                    font.pixelSize: Style.textSizeSmall5
                    background: Rectangle { color: theme.backgroundColor }
                    validator: RegExpValidator { regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/ }
                    onTextChanged:
                    {
                        if (text === "")
                        {
                            API.app.trading_pg.volume = 0
                            text = ""
                        }
                        else
                        {
                            API.app.trading_pg.volume = text;
                            text = API.app.trading_pg.volume;
                        }
                    }
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
                    width: 90
                    height: 30
                    radius: 10
                    border.width: 0
                    color: _mouseArea.containsMouse ? "#8b95ed" : theme.backgroundColor

                    DefaultMouseArea 
                    {
                        id: _mouseArea
                        anchors.fill: parent
                        onClicked: coinsListModalLoader.open()
                        hoverEnabled: true
                    }

                    DefaultImage
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        width: 20
                        height: 20
                        source: General.coinIcon(selectedTicker)
                        DefaultText
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right
                            anchors.leftMargin: 10
                            text: selectedTicker
                            font.pixelSize: Style.textSizeSmall4

                            Arrow 
                            {
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
                    anchors.bottomMargin: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    height: 30
                    text: "0.0"
                    font.pixelSize: Style.textSizeSmall5
                    color: _fromValue.placeholderTextColor
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

                    DefaultMouseArea 
                    {
                        id: _bestOrdersMouseArea
                        anchors.fill: parent
                        onClicked: _bestOrdersModalLoader.open()
                        hoverEnabled: true
                    }

                    DefaultImage // Button with icon (a best order is currently selected)
                    {
                        id: _bestOrderIcon
                        enabled: typeof selectedOrder !== 'undefined'
                        source: General.coinIcon(selectedOrder.coin)
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
                            text: selectedOrder.coin
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
                            _bestOrdersModalLoader.item.selectedOrderChanged.connect(function() 
                            {
                                root.selectedOrder = _bestOrdersModalLoader.item.selectedOrder
                                _bestOrdersModalLoader.close()
                            }) 
                        }
                    }
                }
            }

    DefaultButton
    {
        enabled: parseFloat(_fromValue) > 0 && parseFloat(_toValue) > 0
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: swap_card.width - 30
        text: qsTr("Swap Now !")
    }
        }
    }

    PriceLine // Price
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20
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
            property var selectedOrder
            
            onOpened: API.app.trading_pg.orderbook.refresh_best_orders()
            id: root
            width: 540
            ModalContent 
            {
                title: qsTr("Best Orders")
                DefaultListView
                {
                    Layout.preferredHeight: 450
                    Layout.fillWidth: true
                    model: API.app.trading_pg.orderbook.best_orders.proxy_mdl
                    header: RowLayout // Best orders list header
                    {
                        Layout.fillWidth: true
                        DefaultText
                        {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 220
                            text: qsTr("Available Quantity")
                            font.family: Style.font_family
                            font.bold: true
                            font.weight: Font.Black
                        }
                        DefaultText
                        {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.preferredWidth: 160
                            text: qsTr("Fiat price")
                            font.family: Style.font_family
                            font.bold: true
                            font.weight: Font.Black
                        }

                        DefaultText 
                        {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 80
                            text: qsTr("CEX rate")
                            font.family: Style.font_family
                            font.bold: true
                            font.weight: Font.Black
                        }
                    }
                    delegate: ItemDelegate
                    {
                        width: 480
                        height: 50
                        HorizontalLine { width: parent.width }
                        RowLayout                                // Order info
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            DefaultImage
                            {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                source: General.coinIcon(coin)
                            }
                            DefaultText
                            {
                                Layout.preferredWidth: 180
                                Layout.leftMargin: 5
                                text: "%1 %2".arg(quantity).arg(coin)
                                font.pixelSize: 14
                            }
                            VerticalLine
                            {
                                Layout.preferredHeight: parent.parent.height
                            }
                            DefaultText
                            {
                                Layout.preferredWidth: 150
                                text: price_fiat+API.app.settings_pg.current_fiat_sign
                            }
                            VerticalLine
                            {
                                Layout.preferredHeight: parent.parent.height
                            }
                            DefaultText
                            {
                                Layout.preferredWidth: 150
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
                            else selectedOrder = { "coin": coin, "uuid": uuid }
                        }
                    }
                }
            }
        }
    }
}
