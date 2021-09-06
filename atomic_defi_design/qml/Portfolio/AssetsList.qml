import QtQuick 2.12
import QtQuick.Layouts 1.12

import "../Constants" as Dex
import "../Components" as Dex
import App 1.0 as Dex

Dex.DefaultListView
{
    id: list

    property real _assetRowHeight: 65
    property real _assetNameColumnWidth: 400
    property real _assetNameColumnLeftMargin: 15
    property real _assetBalanceColumnWidth: 320
    property real _assetChange24hColumnWidth: 130
    property real _assetPriceColumWidth: 120

    model: Dex.API.app.portfolio_pg.portfolio_mdl.portfolio_proxy_mdl

    width: parent.width - 50
    height: (count * _assetRowHeight) + 30
    interactive: false
    scrollbar_visible: false

    // Header
    header: RowLayout
    {
        id: columnsHeader

        width: list.width
        height: 40

        Dex.ColumnHeader
        {
            Layout.preferredWidth: _assetNameColumnWidth
            Layout.leftMargin: _assetNameColumnLeftMargin
            icon_at_left: true
            sort_type: sort_by_name
            text: qsTr("Asset")
        }
        Dex.ColumnHeader
        {
            Layout.preferredWidth: _assetBalanceColumnWidth
            icon_at_left: true
            sort_type: sort_by_value
            text: qsTr("Balance")
        }
        Dex.ColumnHeader
        {
            Layout.preferredWidth: _assetChange24hColumnWidth
            icon_at_left: true
            sort_type: sort_by_change
            text: qsTr("Change 24h")
        }
        Dex.ColumnHeader
        {
            Layout.preferredWidth: _assetPriceColumWidth
            icon_at_left: true
            sort_type: sort_by_price
            text: qsTr("Price")
        }
    }

    delegate: Dex.DexRectangle
    {
        width: list.width
        height: _assetRowHeight
        color: mouseArea.containsMouse ? Dex.DexTheme.buttonColorHovered : Dex.DexTheme.contentColorTopBold

        RowLayout
        {
            anchors.fill: parent

            Item // Asset Column.
            {
                Layout.preferredWidth: _assetNameColumnWidth

                Image
                {
                    id: assetImage
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    source: Dex.General.coinIcon(ticker)
                    width: 26
                    height: 26
                }

                Dex.DexLabel
                {
                    id: assetNameLabel
                    anchors.verticalCenter: assetImage.top
                    anchors.left: assetImage.right
                    anchors.leftMargin: _assetNameColumnLeftMargin
                    text: model.ticker

                }

                Dex.DexLabel
                {
                    id: typeTag
                    anchors.verticalCenter: assetImage.bottom
                    anchors.left: assetImage.right
                    anchors.leftMargin: 15

                    text: model.type
                    font: Dex.DexTypo.overLine
                    opacity: .7
                    color: Dex.Style.getCoinTypeColor(model.type)

                    Dex.DexLabel
                    {
                        enabled: name === "Tokel"
                        visible: enabled
                        anchors.left: parent.right
                        anchors.leftMargin: 5

                        text: "IDO"
                        font: Dex.DexTypo.overLine
                        opacity: .7
                        color: Dex.DexTheme.redColor
                    }
                }

            }

            Dex.DexLabel // Balance Column.
            {
                id: assetBalanceLabel

                Layout.preferredWidth: _assetBalanceColumnWidth

                font: Dex.DexTypo.body2
                text_value: Dex.General.formatCrypto("", balance, ticker, main_currency_balance,
                                                     Dex.API.app.settings_pg.current_currency)
                color: Qt.darker(Dex.DexTheme.foregroundColor, 0.8)
                privacy: true
            }

            Dex.DexLabel // Change 24h.
            {
                Layout.preferredWidth: _assetChange24hColumnWidth
                font: Dex.DexTypo.body2
                text_value:
                {
                    const v = parseFloat(change_24h)
                    return v === 0 ? '-' : Dex.General.formatPercent(v)
                }
                color: Dex.DexTheme.getValueColor(change_24h)
            }

            Dex.DexLabel // Price.
            {
                Layout.preferredWidth: _assetPriceColumWidth
                font: Dex.DexTypo.body2
                text_value: Dex.General.formatFiat('', main_currency_price_for_one_unit,
                                                   Dex.API.app.settings_pg.current_currency)
                color: Dex.DexTheme.colorThemeDarkLight
            }

            Dex.CoinMenu { id: contextMenu }
        }

        Dex.DefaultMouseArea
        {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked:
            {
                if (!can_change_ticker)
                    return
                if (mouse.button === Qt.RightButton)
                    contextMenu.popup()
                else
                {
                    api_wallet_page.ticker = ticker
                    dashboard.current_page = idx_dashboard_wallet
                }
            }
            onPressAndHold:
            {
                if (!can_change_ticker)
                    return

                if (mouse.source === Qt.MouseEventNotSynthesized)
                    contextMenu.popup()
            }
        }
    }
}
