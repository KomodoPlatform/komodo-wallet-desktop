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
    height: 40
    visible: true
    width: parent.width-5
    anchors.horizontalCenterOffset: 5
    anchors.horizontalCenter: parent.horizontalCenter
    y: -20
    Connections {
        target: API.app.trading_pg
        function onTradingModeChanged(){
            console.log(API.app.trading_pg.current_trading_mode)
        }
    }

    RowLayout {
        anchors.fill: parent
        Item {
            Layout.preferredWidth: 140
            Layout.fillHeight: true
            Rectangle {
                id: background_rect
                width: 70
                height: 20
                radius: 20
                anchors.verticalCenter: parent.verticalCenter
                color: theme.accentColor
                Behavior on x {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
            RowLayout {
                anchors.fill: parent
                spacing: 0
                DexLabel {
                    text: "Pro"
                    Layout.preferredWidth: 70
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    DexMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            background_rect.x = 0
                            API.app.trading_pg.current_trading_mode = TradingMode.Pro
                        }
                    }
                }
                DexLabel {
                    text: "Simple"
                    Layout.preferredWidth: 70
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    DexMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            background_rect.x = 70
                            API.app.trading_pg.current_trading_mode = TradingMode.Simple
                        }
                    }
                }
            }
            
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        } 
        Qaterial.PopupMenuItem
        {
            implicitHeight: 25
            Qaterial.ColorIcon {
                anchors.centerIn: parent
                source: Qaterial.Icons.cog
                iconSize: 16
                color: theme.accentColor
            } 
        }
        Qaterial.PopupMenuItem
        {
            implicitHeight: 25
            implicitWidth: 25
            leftInset:0
            rightInset:0
            Qaterial.ColorIcon {
                anchors.centerIn: parent
                source: Qaterial.Icons.refresh
                iconSize: 16
                color: theme.accentColor
            } 
        }  
        Qaterial.PopupMenuItem
        {
            implicitHeight: 25
            implicitWidth: 25
            leftInset:0
            rightInset:0
            Qaterial.ColorIcon {
                anchors.centerIn: parent
                source: Qaterial.Icons.cog
                iconSize: 16
                color: theme.accentColor
            } 
        }
    }
}
