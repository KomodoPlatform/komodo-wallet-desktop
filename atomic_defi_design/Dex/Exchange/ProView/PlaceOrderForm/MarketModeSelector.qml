import QtQuick 2.12
import QtQuick.Layouts 1.15

import App 1.0
import Dex.Themes 1.0 as Dex
import AtomicDEX.MarketMode 1.0 as Dex
import "../../../Components"

Rectangle
{
    property int    marketMode: Dex.MarketMode.Sell
    property string ticker: ""
    property string protocolIcon: General.platformIcon(General.coinPlatform(left_ticker))

    radius: 18
    opacity: marketMode != API.app.trading_pg.market_mode ? 0.25: 1

    gradient: Gradient
    {
        orientation: Qt.Horizontal
        GradientStop
        {
            color: marketMode == Dex.MarketMode.Sell ?
                       Dex.CurrentTheme.tradeSellModeSelectorBackgroundColorStart :
                       Dex.CurrentTheme.tradeBuyModeSelectorBackgroundColorStart
            position: 0
        }

        GradientStop
        {
            color: marketMode == Dex.MarketMode.Sell ?
                       Dex.CurrentTheme.tradeSellModeSelectorBackgroundColorEnd :
                       Dex.CurrentTheme.tradeBuyModeSelectorBackgroundColorEnd
            position: 1
        }
    }
    RowLayout
    {
        anchors.centerIn: parent
        spacing: 8

        DexLabel
        {
            color: API.app.trading_pg.market_mode == marketMode ? Dex.CurrentTheme.gradientButtonTextEnabledColor : Dex.CurrentTheme.foregroundColor
            text:
            {
                if (marketMode == Dex.MarketMode.Sell) qsTr("Sell %1", "TICKER").arg(ticker)
                else qsTr("Buy %1", "TICKER").arg(ticker)
            }
        }

        DefaultImage
        {
            id: protocolImg
            visible: protocolIcon != ""
            source: protocolIcon
            Layout.preferredHeight: protocolIcon != "" ? 16 : 0
            Layout.preferredWidth: Layout.preferredHeight
        }
    }

    DefaultMouseArea
    {
        anchors.fill: parent
        enabled: API.app.trading_pg.market_mode != marketMode
        onClicked: API.app.trading_pg.market_mode = marketMode
    }
}
