//! Qt Imports
import QtQuick 2.15          //> Item
import QtQuick.Layouts 1.15  //> RowLayout
import QtQuick.Controls 2.15 //> ItemDelegate

//! Project Imports
import "../../../Components" //> BasicModal
import "../../../Constants"  as Constants // API

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

    onOpened: Constants.API.app.trading_pg.orderbook.refresh_best_orders()
    id: root
    width: 800
    ModalContent
    {
        title: qsTr("Best Orders")
        DefaultListView
        {
            enabled: !Constants.API.app.trading_pg.orderbook.best_orders_busy
            Layout.preferredHeight: 450
            Layout.fillWidth: true
            model: Constants.API.app.trading_pg.orderbook.best_orders.proxy_mdl
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
                        text: price_fiat + Constants.API.app.settings_pg.current_fiat_sign
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
                                    if (Constants.API.app.enable_coins([coin]) === true) _tooltip.close()
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
                    if (!Constants.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled) _tooltip.open()
                    else selectedOrder = { "coin": coin, "uuid": uuid, "price": price, "base_min_volume": base_min_volume, "base_max_volume": base_max_volume }
                }
            }

            BusyIndicator
            {
                width: 200
                height: 200
                visible: !parent.enabled
                running: visible
                anchors.centerIn: parent
            }
        }

        footer:
        [
            DefaultButton
            {
                Layout.fillWidth: true
                text: qsTr("Cancel")
                onClicked: close()
            },
            PrimaryButton
            {
                enabled: !Constants.API.app.trading_pg.orderbook.best_orders_busy
                Layout.fillWidth: true
                text: qsTr("Refresh")
                onClicked: API.app.trading_pg.orderbook.refresh_best_orders()
            }
        ]
    }
}
