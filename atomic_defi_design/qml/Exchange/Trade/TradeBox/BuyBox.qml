import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qt.labs.settings 1.0
import AtomicDEX.MarketMode 1.0

import "../../../Components"
import "../../../Constants"
import "../../../Wallet"

FloatingBackground {
    property alias can_submit_trade: form_base.can_submit_trade
    property alias formBase: form_base
    Layout.preferredHeight: !sell_mode? 250 : 45
    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: 200
        }
    }
    Layout.fillWidth: true
    radius: sell_mode? 3 : 4
    border.color: Style.colorGreen
    color: Style.colorTheme9
    opacity:mouse_area2.containsMouse? 1 : !sell_mode? 1 : .2
    Rectangle {
        width: parent.width
        height: 45
        color: Style.colorGreen
        radius: 2
        DefaultText {
            anchors.centerIn: parent
            text: qsTr("Buy")+" "+left_ticker
            color: Style.colorTheme9
            font.pixelSize: Style.textSize2
        }
    }

    OrderForm {
        id: form_base
        y: 45
        width: parent.width-25
        height: parent.height-45
        clip: true
        visible: !sell_mode
        border.color: 'transparent'
        color: 'transparent'
        anchors.horizontalCenter: parent.horizontalCenter

    }

    DefaultMouseArea {
        anchors.fill: parent
        id: mouse_area2
        visible: sell_mode
        hoverEnabled: true
        onClicked: setMarketMode(MarketMode.Buy)
    }
}
