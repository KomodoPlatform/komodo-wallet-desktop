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
                x: API.app.trading_pg.current_trading_mode != TradingMode.Pro ? 70 : 0
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
                    color: API.app.trading_pg.current_trading_mode == TradingMode.Pro ? theme.surfaceColor : theme.foregroundColor
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
                    color: API.app.trading_pg.current_trading_mode == TradingMode.Simple ? theme.surfaceColor : theme.foregroundColor
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
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            color: tuto_area.containsMouse? 'transparent' : theme.accentColor
            Row {
                anchors.centerIn: parent
                spacing: 10
                Qaterial.ColorIcon {
                    source: Qaterial.Icons.televisionPlay
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 15
                    color: tuto_area.containsMouse? theme.accentColor : theme.surfaceColor
                }
                DexLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.Medium
                    color: tuto_area.containsMouse? theme.accentColor : theme.surfaceColor
                    text: qsTr("How to trade")
                }
            }
            DexMouseArea {
                id: tuto_area
                hoverEnabled: true
                anchors.fill: parent
            }
        }
        Rectangle {
            width: 50
            height: 25
            radius: height/2
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            color: faq_area.containsMouse? 'transparent' : theme.accentColor
            Row {
                anchors.centerIn: parent
                spacing: 10
                DexLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.Medium
                    color: faq_area.containsMouse? theme.accentColor : theme.surfaceColor
                    text: qsTr("FAQ")
                }
            }
            DexMouseArea {
                id: faq_area
                hoverEnabled: true
                anchors.fill: parent
            }
        }  
        Rectangle {
            width: 40
            height: 25
            radius: height/2
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            color: cog_area.containsMouse? 'transparent' :  form.dexConfig.visible? 'transparent' : theme.accentColor
            Row {
                anchors.centerIn: parent
                spacing: 10
                Qaterial.ColorIcon {
                    source: Qaterial.Icons.cog
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 15
                    color: cog_area.containsMouse? theme.accentColor : form.dexConfig.visible? theme.accentColor : theme.surfaceColor 
                }
            }
            DexMouseArea {
                id: cog_area
                hoverEnabled: true
                anchors.fill: parent
                onClicked: {
                    if(form.dexConfig.visible){
                        form.dexConfig.close()
                    }else {
                        form.dexConfig.openAt(mapToItem(Overlay.overlay, width / 2, height), Item.Top)
                    }
                    
                }
            }
        }
    }
}
