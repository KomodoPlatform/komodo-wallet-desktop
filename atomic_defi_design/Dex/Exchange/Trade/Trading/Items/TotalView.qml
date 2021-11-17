import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import "../../../../Components"
import "../../../../Constants"
import Dex.Themes 1.0 as Dex

Item
{
    anchors.fill: parent
    anchors.topMargin: 0
    Item
    {
        width: parent.width
        height: 140
        Column
        {
            width: parent.width-15
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            leftPadding: 10
            rightPadding: 10
            RowLayout
            {
                width: parent.width
                height: 30
                DefaultText
                {
                    color: Dex.CurrentTheme.foregroundColor3
                    text: "Total " + API.app.settings_pg.current_fiat + " " + General.cex_icon
                    font.pixelSize:  14
                    font.weight: Font.Normal
                    opacity: .6
                    CexInfoTrigger {}
                }
                Item
                {
                    height: 30
                    Layout.fillWidth: true
                    DefaultText
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 20
                        anchors.right: parent.right
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        font.family: 'lato'
                        text_value: General.getFiatText(total_amount, right_ticker).replace(General.cex_icon, "")
                    }
                }
            }
            
            HorizontalLine
            {
                color: Dex.CurrentTheme.lineSeparatorColor
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            RowLayout
            {
                width: parent.width
                height: 30
                DexLabel
                {
                    color: Dex.CurrentTheme.foregroundColor3
                    text:  "Total " + atomic_qt_utilities.retrieve_main_ticker(right_ticker)
                    font.pixelSize:  14
                    opacity: .6
                    font.weight: Font.Normal
                }
                Item
                {
                    height: 30
                    Layout.fillWidth: true
                    DefaultText
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 20
                        anchors.right: parent.right
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        font.family: 'lato'
                        text_value: General.formatCrypto("", total_amount, right_ticker).replace(right_ticker, "")
                    }
                }
            }
        }
    }
}
