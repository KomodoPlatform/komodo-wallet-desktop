import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0


import "../../../../Components"
import "../../../../Constants"


Item {
    anchors.fill: parent
    anchors.topMargin: 0
    Item {
        width: parent.width
        height: 80
        Column {
            width: parent.width-15
            anchors.centerIn: parent
            spacing: 0
            RowLayout {
                width: parent.width
                DefaultText {
                    color: theme.foregroundColor
                    text:"Total "+API.app.settings_pg.current_fiat+" "+General.cex_icon
                    font.pixelSize:  13
                    Layout.preferredWidth: 120
                    font.weight: Font.Regular
                    CexInfoTrigger {}
                }
                Item {
                    height: 40
                    Layout.fillWidth: true
                    DefaultText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        font.weight: Font.DemiBold
                        font.pixelSize: 12
                        font.family: 'lato'
                        color: theme.accentColor
                        text_value: General.getFiatText(total_amount, right_ticker).replace(General.cex_icon,"")

                    }
                }
            }


            RowLayout {
                width: parent.width
                DefaultText {
                    color: theme.foregroundColor
                    text:  "Total "+ atomic_qt_utilities.retrieve_main_ticker(right_ticker)
                    font.pixelSize:  13
                    Layout.preferredWidth: 120
                    font.weight: Font.Regular

                }
                Item {
                    height: 40
                    Layout.fillWidth: true
                    DefaultText {
                        text_value: General.formatCrypto("", total_amount, right_ticker).replace(right_ticker,"")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        font.weight: Font.DemiBold
                        font.pixelSize: 12
                        font.family: 'lato'
                        color: theme.accentColor
                    }
                }
            }
        }
    }
}
