import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0

import "../" as OtherPage

import "../../../Components"
import "../../../Constants"


Item {
    height: 25
    visible: true

    width: parent.width+10
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
            color: Style.colorWhite2
            text: API.app.trading_pg.multi_order_enabled? qsTr("Trading Mode - Multi Ordering") : qsTr("Trading Mode - Single Order")
        }
        Qaterial.AppBarButton {
            Layout.alignment: Qt.AlignVCenter
            Layout.topMargin: 6
            icon.source: Qaterial.Icons.cog
            onClicked: p.open()
        }
        VerticalLine {
            Layout.fillHeight: true
        }

        Qaterial.LatoTabBar {
            Layout.alignment: Qt.AlignVCenter
            Qaterial.LatoTabButton {
                text: qsTr("Pro-Mode")
                textColor: Style.colorWhite2
                textSecondaryColor: Style.colorWhite8
            }
            Qaterial.LatoTabButton {
                text: qsTr("Starter")
                textSecondaryColor: Style.colorWhite8
                textColor: Style.colorWhite2
                ToolTip.text: "(Under Work)"

            }
        }
    }
}
