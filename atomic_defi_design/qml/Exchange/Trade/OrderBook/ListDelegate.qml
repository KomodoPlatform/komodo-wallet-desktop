import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

Item {
    property bool isAsk
    width: visible? orderList.width : 0
    height: 36

    AnimatedRectangle {
        visible: mouse_are.containsMouse
        width: parent.width
        height: parent.height
        color: theme.foregroundColor
        opacity: 0.1
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: 6
        radius: width/2
        x: 3
        visible: is_mine
        color: isAsk? Style.colorRed : Style.colorGreen
    }
    HorizontalLine {
        width: parent.width
        opacity: .4
    }
    Rectangle {
        id: progress
        height: 2
        anchors.bottom: parent.bottom
        radius: 3
        x: 10
        color: isAsk? Style.colorRed : Style.colorGreen
        width: 0
        Component.onCompleted: width =((depth * 100) * (parent.width + 40)) / 100
        opacity: 0.8//!isVertical? 1.1-(index * 0.1) :  1-(1.1-(index * 0.1))
        Behavior on width {
            NumberAnimation {
                duration: 1000
            }
        }
        //anchors.verticalCenter: parent.verticalCenter
    }
    RowLayout {
        id: row
        width:  mouse_are.containsMouse?  parent.width - 15 : parent.width - 30
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        onWidthChanged: progress.width = ((depth * 100) * (width + 40)) / 100
        spacing: 10
        Qaterial.ColorIcon {
            visible: mouse_are.containsMouse &&  !enough_funds_to_pay_min_volume //(min_volume > 0 && API.app.trading_pg.orderbook.base_max_taker_vol.decimal < min_volume) && min_volume !== API.app.trading_pg.mm2_min_volume
            source: Qaterial.Icons.alert
            Layout.alignment: Qt.AlignVCenter
            iconSize: 13
            color: Qaterial.Colors.amber
        }
        DefaultTooltip {
            visible: mouse_are.containsMouse && !enough_funds_to_pay_min_volume //(min_volume > 0 && API.app.trading_pg.orderbook.base_max_taker_vol.decimal < min_volume) && min_volume !== API.app.trading_pg.mm2_min_volume
            width: 300
            contentItem: DefaultText {
                text_value: qsTr("This order require a minimum amount of %1 %2 <br>You don't have enough funds.<br> Your max balance after fees is: (%3)").arg(min_volume).arg(isAsk ? API.app.trading_pg.market_pairs_mdl.right_selected_coin : API.app.trading_pg.market_pairs_mdl.left_selected_coin).arg(isAsk ? API.app.trading_pg.orderbook.rel_max_taker_vol.decimal : API.app.trading_pg.orderbook.base_max_taker_vol.decimal)
                wrapMode: DefaultText.Wrap
                width: 300
            }
            delay: 200
        }
        DexLabel {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 60
            text: parseFloat(General.formatDouble(
                                 price, General.amountPrecision, true)).toFixed(8)
            font.family: _font.fontFamily
            font.pixelSize: 11
            color: isAsk? Style.colorRed : Style.colorGreen

        }
        DexLabel {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 100
            text: parseFloat(quantity).toFixed(6)
            font.family: _font.fontFamily
            font.pixelSize: 11
            horizontalAlignment: Label.AlignRight
            opacity: 1

        }
        DexLabel {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            text: parseFloat(total).toFixed(8)
            Behavior on rightPadding {
                NumberAnimation {
                    duration: 150
                }
            }
            rightPadding: (is_mine) && (mouse_are.containsMouse || cancel_button.containsMouse) ? 30 : 0
            horizontalAlignment: Label.AlignRight
            font.family: _font.fontFamily
            font.pixelSize: 11
            opacity: 1

        }
    }


    DefaultMouseArea {
        id: mouse_are
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if(is_mine) return

            if(!enough_funds_to_pay_min_volume ){

            }
            else {
                exchange_trade.orderSelected = true
                orderList.currentIndex = index
                if(isAsk) {
                    selectOrder(true, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume, base_min_volume, base_max_volume, rel_min_volume, rel_max_volume, base_max_volume_denom, base_max_volume_numer, uuid)
                }else {
                    selectOrder(false, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume, base_min_volume, base_max_volume, rel_min_volume, rel_max_volume, base_max_volume_denom, base_max_volume_numer, uuid)
                }
            }


        }
    }

    Qaterial.ColorIcon {
        id: cancel_button_text
        property bool requested_cancel: false
        visible: is_mine && !requested_cancel

        source: Qaterial.Icons.close
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1
        anchors.right: parent.right
        anchors.rightMargin:  mouse_are.containsMouse || cancel_button.containsMouse? 12 : 6
        Behavior on iconSize {
            NumberAnimation {
                duration: 200
            }
        }

        iconSize: mouse_are.containsMouse || cancel_button.containsMouse? 16 : 0

        color: cancel_button.containsMouse ? Qaterial.Colors.red : mouse_are.containsMouse? Style.colorText2 : Qaterial.Colors.red

        DefaultMouseArea {
            id: cancel_button
            anchors.fill: parent
            hoverEnabled: true


            onClicked: {
                if(!is_mine) return

                cancel_button_text.requested_cancel = true
                cancelOrder(uuid)
            }
        }
    }
    AnimatedRectangle {
        visible: !enough_funds_to_pay_min_volume && mouse_are.containsMouse
        color: Style.colorTheme9
        anchors.fill: parent
        opacity: .3
    }

    
}
