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
        height: 70
        Column {
            width: parent.width-15
            anchors.centerIn: parent
            spacing: 0
            leftPadding: 10
            rightPadding: 10
            RowLayout {
                width: parent.width
                DefaultText {
                    color: theme.foregroundColor
                    text: "TOTAL "+API.app.settings_pg.current_fiat+" "+General.cex_icon
                    font.pixelSize:  11
                    Layout.preferredWidth: 120
                    font.weight: Font.Regular
                    opacity: .7
                    CexInfoTrigger {}
                }
                Item {
                    height: 30
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
                    text:  "TOTAL "+ atomic_qt_utilities.retrieve_main_ticker(right_ticker)
                    font.pixelSize:  11
                    Layout.preferredWidth: 120
                    opacity: .7
                    font.weight: Font.Regular

                }
                Item {
                    height: 30
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
