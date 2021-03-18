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
            width: parent.width-60
            anchors.centerIn: parent
            spacing: 0
            RowLayout {
                width: parent.width
                DefaultText {
                    color: theme.foregroundColor
                    text:"Total "+API.app.settings_pg.current_fiat+" "+General.cex_icon
                    font.pixelSize:  Style.textSizeSmall5
                    Layout.preferredWidth: 120
                    font.weight: Font.DemiBold
                    CexInfoTrigger {}
                }
                Item {
                    height: 40
                    Layout.fillWidth: true
                    DefaultText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        font.weight: Font.Light
                        font.pixelSize: Style.textSizeSmall4
                        text_value: General.getFiatText(total_amount, right_ticker).replace(General.cex_icon,"")

                    }
                }
            }
            HorizontalLine {
                width: parent.width-50
                anchors.horizontalCenter: parent.horizontalCenter
            }

            RowLayout {
                width: parent.width
                DefaultText {
                    color: theme.foregroundColor
                    text:  "Total "+right_ticker
                    font.pixelSize:  Style.textSizeSmall5
                    Layout.preferredWidth: 120
                    font.weight: Font.DemiBold

                }
                Item {
                    height: 40
                    Layout.fillWidth: true
                    DefaultText {
                        text_value: General.formatCrypto("", total_amount, right_ticker).replace(right_ticker,"")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        font.weight: Font.Light
                        font.pixelSize: Style.textSizeSmall4
                    }
                }
            }
        }
    }
}
