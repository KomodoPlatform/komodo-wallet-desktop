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
                    color: background_rect.x===0? theme.surfaceColor :  theme.foregroundColor
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
                    color: background_rect.x!==0? theme.surfaceColor :  theme.foregroundColor
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
        Rectangle {
            width: 140
            height: 25
            radius: height/2
            color: theme.accentColor
            Row {
                anchors.centerIn: parent
                spacing: 10
                Qaterial.ColorIcon {
                    source: Qaterial.Icons.televisionPlay
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 15
                    color: theme.surfaceColor
                }
                DexLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.Medium
                    color: theme.surfaceColor
                    text: qsTr("How to trade")
                }
            }
        }
        Rectangle {
            width: 50
            height: 25
            radius: height/2
            color: theme.accentColor
            Row {
                anchors.centerIn: parent
                spacing: 10
                DexLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.Medium
                    color: theme.surfaceColor
                    text: qsTr("FAQ")
                }
            }
        }  
        Rectangle {
            width: 40
            height: 25
            radius: height/2
            color: theme.accentColor
            Row {
                anchors.centerIn: parent
                spacing: 10
                Qaterial.ColorIcon {
                    source: Qaterial.Icons.cog
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 15
                    color: theme.surfaceColor
                }
            }
        }
    }
}
