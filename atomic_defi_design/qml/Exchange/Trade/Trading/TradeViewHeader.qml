import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0

import AtomicDEX.TradingMode 1.0

import "../" as OtherPage

import "../../../Components"
import "../../../Constants"


Item {
    height: 25
    visible: true

    width: parent.width+10
    Connections {
        target: API.app.trading_pg
        function onTradingModeChanged(){
            console.log(API.app.trading_pg.current_trading_mode)
        }
    }

    RowLayout {
        width: parent.width-20
        anchors.fill: parent
        anchors.rightMargin: 20
        DefaultText {
            leftPadding: 20
            topPadding: 5
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            font.family: 'Ubuntu'
            font.pixelSize: 20
            font.weight: Font.Light
            color: theme.foregroundColor
            text: API.app.trading_pg.multi_order_enabled? qsTr("Trading Mode - Multi Ordering") : qsTr("Trading Mode - Single Order")
        }
        VerticalLine {
            Layout.fillHeight: true
        }

        Qaterial.LatoTabBar {
            Layout.alignment: Qt.AlignVCenter
            Qaterial.LatoTabButton {
                text: qsTr("Pro-Mode")
                textColor: theme.foregroundColor
                textSecondaryColor: Qt.darker(theme.foregroundColor,0.8)
                onCheckedChanged: {
                    if(checked) {
                        API.app.trading_pg.current_trading_mode = TradingMode.Pro
                    }
                }
                
            }
            Qaterial.LatoTabButton {
                text: qsTr("Starter")
                textSecondaryColor: Qt.darker(theme.foregroundColor,0.8)
                textColor: theme.foregroundColor
                ToolTip.text: "(Under Work)"
                onCheckedChanged: {
                    if(checked) {
                        API.app.trading_pg.current_trading_mode = TradingMode.Simple
                    }
                }

            }
        }
    }
}
