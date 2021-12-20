import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0
import AtomicDEX.MarketMode 1.0

import "../../../Components"
import "../../../Wallet"

import App 1.0

Item {
    property alias can_submit_trade: form_base.can_submit_trade
    property alias formBase: form_base
    Layout.preferredHeight: sell_mode ? 350 : 45
    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: 200
        }
    }
    //color: Style.colorTheme
    Layout.fillWidth: true
    //radius: sell_mode? 4 : 3
    //border.color: Style.colorRed
    //color: Style.colorTheme6
    opacity: mouse_area.containsMouse ? 1 : sell_mode ? 1 : .35

    Rectangle {
        visible: false
        width: parent.width
        height: 45
        color: Style.colorRed
        radius: 6
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.radius
            color: Style.colorTheme6
        }

        DefaultText {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            text: qsTr("Sell") + " " + atomic_qt_utilities.retrieve_main_ticker(left_ticker)
            color: Qaterial.Colors.gray200
            font.pixelSize: Style.textSize1
        }
    }
    OrderForm {
        id: form_base
        y: 45
        width: parent.width - 25
        height: parent.height - 45
        //clip: true
        visible: sell_mode
        border.color: 'transparent'
        color: 'transparent'
        anchors.horizontalCenter: parent.horizontalCenter

    }






    DefaultMouseArea {
        anchors.fill: parent
        id: mouse_area
        visible: !sell_mode
        hoverEnabled: true
        onClicked: setMarketMode(MarketMode.Sell)
    }
}