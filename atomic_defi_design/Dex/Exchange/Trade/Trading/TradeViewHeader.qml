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

Item
{
    width: parent.width - 5
    anchors.horizontalCenter: parent.horizontalCenter

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 50

        // Simple/Pro toggle group
        Item
        {
            Layout.leftMargin: 30
            Layout.preferredWidth: 120

            // Simple/Pro select cursor
            Rectangle
            {
                width: 84
                height: 32
                radius: 18
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: API.app.trading_pg.current_trading_mode == TradingMode.Simple ? _simpleLabel.horizontalCenter : _proLabel.horizontalCenter
                color: Dex.CurrentTheme.tabSelectedColor
            }

            DexLabel
            {
                id: _simpleLabel
                text: "Simple"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
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
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
                DexMouseArea
                {
                    id: pro_area
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: API.app.trading_pg.current_trading_mode = TradingMode.Pro
                }
            }
        }
        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
        } 
    }
}
