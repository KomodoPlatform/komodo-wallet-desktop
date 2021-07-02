//! Qt Imports
import QtQuick 2.15          //> Item
import QtQuick.Layouts 1.15  //> RowLayout
import QtQuick.Controls 2.15 //> ItemDelegate

//! Project Imports
import "../../../Components" //> BasicModal
import "../../../Constants"  //> API

DefaultListView
{
    id: _listBestOrdersView

    property var    tradeCard
    property var    selectedOrder
    property bool best: true
    property string currentLeftToken // The token we wanna sell

    property int    _rowWidth: width - 20
    property int    _rowHeight: 50
    property int    _tokenColumnSize: 60
    property int    _quantityColumnSize: 100
    property int    _quantityInBaseColumnSize: 100
    property int    _fiatVolumeColumnSize: 50
    property int    _cexRateColumnSize: 50

    enabled: !API.app.trading_pg.orderbook.best_orders_busy
    model: API.app.trading_pg.orderbook.best_orders.proxy_mdl
    headerPositioning: ListView.OverlayHeader
    reuseItems: true
    cacheBuffer: 40
    clip: true

    Connections
    {
        target: _tradeCard
        function onBestChanged()
        {
            API.app.trading_pg.orderbook.best_orders.proxy_mdl.setFilterFixedString("")
            positionViewAtBeginning()
        }
    }

    onVisibleChanged: currentLeftToken = _tradeCard.selectedTicker

    header: DexRectangle // Best orders list header
    {
        width: _rowWidth
        height: _rowHeight
        border.color: 'transparent'
        color: theme.dexBoxBackgroundColor
        z: 2
        radius: 0

        MouseArea { anchors.fill: parent }
        RowLayout                   // Order Columns Name
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.fill: parent
            DexLabel             // "Token" Header
            {
                Layout.preferredWidth: _tokenColumnSize
                text: qsTr("Token")
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
            }
            DexLabel             // "Available Quantity" Header
            {
                Layout.preferredWidth: _quantityColumnSize
                text: qsTr("Available Quantity")
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
            }
            DexLabel             // "Available Quantity (in BASE)" header
            {
                Layout.preferredWidth: _quantityInBaseColumnSize
                text: qsTr("Available Quantity (in %1)").arg(currentLeftToken)
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
            }
            DexLabel             // "Fiat Volume" column header
            {
                Layout.preferredWidth: _fiatVolumeColumnSize
                text: qsTr("Fiat Volume")
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
            }
            DexLabel             // "CEX Rate" column header
            {
                Layout.preferredWidth: _cexRateColumnSize
                text: qsTr("CEX Rate")
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
            }
        }
    }

    delegate: ItemDelegate // Order Line
    {
        property bool _isCoinEnabled: API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled

        width: _rowWidth
        height: _rowHeight

        HorizontalLine { width: parent.width; opacity: .5 }

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
                    opacity: !_isCoinEnabled? .1 : 1
                }
                DefaultText                          // Order Token Name
                {
                    id: _tokenName
                    Layout.preferredWidth: _tokenColumnSize - parent._iconWidth
                    text: coin
                    font.pixelSize: 14
                }
            }
            
            DefaultText                         // Order Available Quantity
            {
                Layout.preferredWidth: _quantityColumnSize
                text: parseFloat(General.formatDouble(quantity, General.amountPrecision, true)).toFixed(8)
                font.pixelSize: 14
            }
            
            DefaultText                         // Order Available Quantity In BASE
            {
                Layout.preferredWidth: _quantityInBaseColumnSize
                text: parseFloat(General.formatDouble(base_max_volume, General.amountPrecision, true)).toFixed(8)
                font.pixelSize: 14
            }
            
            DefaultText                         // Order Fiat Volume
            {
                Layout.preferredWidth: _fiatVolumeColumnSize
                text: price_fiat+API.app.settings_pg.current_fiat_sign
            }
            
            DefaultText
            {
                Layout.preferredWidth: _cexRateColumnSize
                color: cex_rates=== "0" ? Qt.darker(theme.foregroundColor) : parseFloat(cex_rates)>0? theme.redColor : theme.greenColor
                text: cex_rates=== "0" ? "N/A" : parseFloat(cex_rates)>0? "+"+parseFloat(cex_rates).toFixed(2)+"%" : parseFloat(cex_rates).toFixed(2)+"%"
            }
            DefaultTooltip
            {
                id: _tooltip

                width: 250

                dim: true
                modal: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                contentItem: DexLabelUnlinked
                {
                    text_value: qsTr(" %1 is not enabled - Do you want to enable it to be able to select %2 best orders ?<br><a href='#'>Yes</a> - <a href='#no'>No</a>").arg(coin).arg(coin)
                    wrapMode: DefaultText.Wrap
                    width: 250
                    onLinkActivated:
                    {
                        if (link === "#no") _tooltip.close()
                        else
                        {
                            if (API.app.enable_coins([coin]) === false)
                                cannot_enable_coin_modal.open()
                            else
                            {
                                color = theme.buttonColorTextDisabled
                                opacity = 0.8
                                _coinIsEnabling.visible = true
                             }
                        }
                    }
                }

                BusyIndicator
                {
                    id: _coinIsEnabling

                    visible: false
                    enabled: visible
                    anchors.fill: parent

                    Connections
                    {
                        target: API.app.portfolio_pg.global_cfg_mdl.all_disabled_proxy

                        function onLengthChanged()
                        {
                            _tooltip.close()
                            _isCoinEnabled = API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled
                        }
                     }
                }

                ModalLoader
                {
                    property string coin_to_enable_ticker: coin
                    id: cannot_enable_coin_modal
                    sourceComponent: CannotEnableCoinModal { coin_to_enable_ticker: cannot_enable_coin_modal.coin_to_enable_ticker }
                }

                delay: 200
            }
        }
        onClicked:
        {
            if (!API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled)
            {
                _tooltip.open()
            }
            else
            {
                _listBestOrdersView.tradeCard.best = false
                _listBestOrdersView.selectedOrder = { "coin": coin, "uuid": uuid, "price": price, "base_min_volume": base_min_volume, "base_max_volume": base_max_volume, "from_best_order": true }
            }
        }
    }
    DexLabel {
        anchors.centerIn: parent
        text: qsTr('No best order.')
        visible: parent.count==0
    }
}
