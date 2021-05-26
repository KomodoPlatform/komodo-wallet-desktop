import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"
import "./BestOrder" as BestOrder

ColumnLayout
{
    property string selectedTicker: "KMD"
    property var    selectedOrder

    id: root
    anchors.centerIn: parent
    DefaultRectangle
    {
        id: swap_card
        width: 370
        height: 360
        radius: 20

        ColumnLayout // Header
        {
            id: swap_card_desc

            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 20

            RowLayout
            {
                DefaultText
                {
                    Layout.preferredWidth: swap_card.width - 70
                    id: title
                    text: qsTr("Swap")
                    font.pixelSize: Style.textSize1
                }
            }

            DefaultText // Description
            {
                Layout.topMargin: 6
                font.pixelSize: Style.textSizeSmall4
                text: qsTr("Instant trading with best orders")
            }

            HorizontalLine
            {
                Layout.topMargin: 12
                Layout.fillWidth: true
            }
        }

        ColumnLayout
        {
            anchors.top: swap_card_desc.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.horizontalCenter: parent.horizontalCenter

            // From
            DefaultRectangle
            {
                id: swap_from_card
                Layout.preferredWidth: swap_card.width - 20
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignHCenter

                DefaultText
                {
                    anchors.fill: parent
                    anchors.leftMargin: 25
                    anchors.topMargin: 10
                    text: qsTr("From")
                    font.pixelSize: Style.textSizeSmall5
                }

                TextField
                {
                    id: from_value
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    height: 30
                    placeholderText: "0.0"
                    font.pixelSize: Style.textSize1
                    background: Rectangle { color: theme.backgroundColor }
                    validator: RegExpValidator { regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/ }
                    onTextChanged:
                    {
                        API.app.trading_pg.volume = text;
                        text = API.app.trading_pg.volume;
                    }
                }

                DefaultText
                {
                    color: from_value.color
                }

                Rectangle
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    width: 100
                    height: 40
                    radius: 20
                    border.width: 0
                    color: _mouseArea.containsMouse ? Style.colorSidebarHighlightGradient4 : theme.backgroundColor

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
                        function onLoaded()
                        {
                            coinsListModalLoader.item.selectedTickerChanged.connect(function() {root.selectedTicker = coinsListModalLoader.item.selectedTicker})
                        }
                    }
                }
            }

            // To
            DefaultRectangle
            {
                Layout.preferredWidth: swap_card.width - 20
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 15
                radius: 20

                DefaultText
                {
                    anchors.fill: parent
                    anchors.leftMargin: 25
                    anchors.topMargin: 10
                    text: qsTr("To")
                    font.pixelSize: Style.textSizeSmall5
                }

                DefaultText
                {
                    color: from_value.color
                    enabled: false
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    height: 30
                    text: "0.0"
                    font.pixelSize: Style.textSize1
                }

                DefaultRectangle // Shows best order coin
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    width: 100
                    height: 40
                    radius: 20
                    border.width: 0
                    color: theme.backgroundColor

                    DefaultImage
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        width: 20
                        height: 20
                        source: General.coinIcon(selectedOrder.coin)
                        DefaultText
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right
                            anchors.leftMargin: 10
                            text: selectedOrder.coin
                        }
                    }
                }
            }
            DefaultButton
            {
                Layout.topMargin: 10
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Pick from best orders")
                onClicked: _bestOrdersModalLoader.open()

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
                        _bestOrdersModalLoader.item.selectedOrderChanged.connect(function() {root.selectedOrder = _bestOrdersModalLoader.item.selectedOrder})
                    }
                }
            }
        }
    }

    DefaultButton
    {
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: swap_card.width
        text: qsTr("Swap Now !")
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
            
            onOpened: 
            {
                API.app.trading_pg.set_pair(true, "KMD")
                API.app.trading_pg.orderbook.refresh_best_orders()
            }
            id: root
            width: 500
            ModalContent 
            {
                title: qsTr("Best Orders")
                DefaultListView
                {
                    model: API.app.trading_pg.orderbook.best_orders.proxy_mdl
                    header: RowLayout // Best orders list header
                    {
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
                        id: root
                        width: 480
                        height: 50
                        HorizontalLine
                        {
                            width: parent.width
                        }
                        RowLayout   // Order info
                        {
                            anchors.verticalCenter: parent.verticalCenter
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
                            if(!API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled)
                            {
                                _tooltip.open()
                            }
                            else 
                            {
                                selectedOrder = model
                                app.pairChanged(base_ticker, coin)
                                API.app.trading_pg.orderbook.select_best_order(uuid)
                            }
                        }
                    }
                }
            }
        }
    }
}
