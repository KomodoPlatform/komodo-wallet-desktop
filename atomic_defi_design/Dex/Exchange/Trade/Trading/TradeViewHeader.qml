import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0
import AtomicDEX.TradingMode 1.0
import "../../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

// Simple/Pro toggle group
Item
{
    // Simple/Pro select cursor
    Rectangle
    {
        width: 86
        height: 34
        radius: 18
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: API.app.trading_pg.current_trading_mode == TradingMode.Simple ? _simpleLabel.horizontalCenter : _proLabel.horizontalCenter
        color: Dex.CurrentTheme.tabSelectedColor
    }

    DexLabel
    {
        id: _simpleLabel
        text: "Simple"
        color: API.app.trading_pg.current_trading_mode == TradingMode.Simple ? Dex.CurrentTheme.foregroundColor2 : Dex.CurrentTheme.foregroundColor
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 16
        font.weight: Font.Bold

        DexMouseArea
        {
            id: simple_area
            hoverEnabled: true
            anchors.fill: parent
            onClicked: API.app.trading_pg.current_trading_mode = TradingMode.Simple
        }
    }

    DexLabel
    {
        id: _proLabel
        text: "Pro"
        color: API.app.trading_pg.current_trading_mode == TradingMode.Pro ? Dex.CurrentTheme.foregroundColor2 : Dex.CurrentTheme.foregroundColor
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 16
        font.weight: Font.Bold

        DexMouseArea
        {
            id: pro_area
            hoverEnabled: true
            anchors.fill: parent
            onClicked: API.app.trading_pg.current_trading_mode = TradingMode.Pro
        }
    }
}
