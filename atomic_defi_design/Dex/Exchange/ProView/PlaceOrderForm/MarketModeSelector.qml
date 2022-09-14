import QtQuick 2.12

import App 1.0
import Dex.Themes 1.0 as Dex
import AtomicDEX.MarketMode 1.0 as Dex
import "../../../Components"

Rectangle
{
    property int    marketMode: Dex.MarketMode.Sell
    property string ticker: ""

    radius: 18

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

    // Background on topover of gradient to hide it when the market mode is different
    DefaultRectangle
    {
        anchors.centerIn: parent
        width: parent.width - 2
        height: parent.height - 2
        radius: parent.radius - 1
        color: Dex.CurrentTheme.backgroundColor
        visible: marketMode != API.app.trading_pg.market_mode
    }

    // Background when market mode is different
    DefaultRectangle
    {
        anchors.centerIn: parent
        width: parent.width - 2
        height: parent.height - 2
        radius: parent.radius - 1
        color: Dex.CurrentTheme.tradeMarketModeSelectorNotSelectedBackgroundColor
        visible: marketMode != API.app.trading_pg.market_mode
    }

    DefaultText
    {
        anchors.centerIn: parent
        color: API.app.trading_pg.market_mode == marketMode ? Dex.CurrentTheme.gradientButtonTextEnabledColor : Dex.CurrentTheme.foregroundColor
        text:
        {
            if (marketMode == Dex.MarketMode.Sell) qsTr("Sell %1", "TICKER").arg(ticker)
            else qsTr("Buy %1", "TICKER").arg(ticker)
        }
    }

    DefaultMouseArea
    {
        anchors.fill: parent
        enabled: API.app.trading_pg.market_mode != marketMode
        onClicked: API.app.trading_pg.market_mode = marketMode
    }
}
