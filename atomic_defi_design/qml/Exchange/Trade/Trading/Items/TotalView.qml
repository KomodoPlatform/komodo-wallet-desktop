import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0


import "../../../../Components"
import App 1.0


Item {
    anchors.fill: parent
    anchors.topMargin: 0
    Item {
        width: parent.width
        height: 140
        Column {
            width: parent.width-15
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            leftPadding: 10
            rightPadding: 10
            RowLayout {
                width: parent.width
                height: 30
                DefaultText {
                    color: DexTheme.foregroundColor
                    text: "TOTAL "+API.app.settings_pg.current_fiat+" "+General.cex_icon
                    font.pixelSize:  14
                    font.weight: Font.Normal
                    opacity: .6
                    CexInfoTrigger {}
                }
                Item {
                    height: 30
                    Layout.fillWidth: true
                    DefaultText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 20
                        anchors.right: parent.right
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        font.family: 'lato'
                        color: DexTheme.accentColor
                        text_value: General.getFiatText(total_amount, right_ticker).replace(General.cex_icon,"")
                    }
                }
            }
            
            Rectangle {
                color: DexTheme.foregroundColor
                opacity: .2
                height: 1.5
                width:parent.width-20
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            RowLayout {
                width: parent.width
                height: 30
                DexLabel {
                    color: DexTheme.foregroundColor
                    text:  "TOTAL "+ atomic_qt_utilities.retrieve_main_ticker(right_ticker)
                    font.pixelSize:  14
                    opacity: .6
                    font.weight: Font.Normal
                }
                Item {
                    height: 30
                    Layout.fillWidth: true
                    DefaultText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 20
                        anchors.right: parent.right
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        font.family: 'lato'
                        color: DexTheme.accentColor
                        text_value: General.formatCrypto("", total_amount, right_ticker).replace(right_ticker,"")
                    }
                }
            }
        }
    }
}
