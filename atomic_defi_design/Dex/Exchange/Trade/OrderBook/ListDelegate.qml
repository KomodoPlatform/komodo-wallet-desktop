import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

Item
{
    property bool isAsk

    AnimatedRectangle
    {
        visible: mouse_are.containsMouse
        width: parent.width
        height: parent.height
        color: Dex.CurrentTheme.foregroundColor
        opacity: 0.1
    }

    Rectangle
    {
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: 6
        radius: width / 2
        visible: is_mine
        color: isAsk ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
    }

    // Progress bar
    Rectangle
    {
        anchors.bottom: parent.bottom
        height: 2
        radius: 3
        color: Dex.CurrentTheme.backgroundColor
        width: parent.width

        Rectangle
        {
            anchors.top: parent.top
            height: 2
            radius: 3
            color: isAsk ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
            width: 0
            Component.onCompleted: width = ((depth * 100) * (parent.parent.width + 40)) / 100
            opacity: 0.8
            Behavior on width { NumberAnimation { duration: 1000 } }
        }
    }

    RowLayout
    {
        id: row
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        onWidthChanged: progress.width = ((depth * 100) * (width + 40)) / 100

        Qaterial.ColorIcon
        {
            visible: mouse_are.containsMouse && !enough_funds_to_pay_min_volume
            source: Qaterial.Icons.alert
            Layout.alignment: Qt.AlignVCenter
            iconSize: 12
            color: Qaterial.Colors.amber
        }

        // Price
        DefaultText
        {
            Layout.preferredWidth: (parent.width / 100) * 30
            text: parseFloat(General.formatDouble(price, General.amountPrecision, true)).toFixed(8)
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            color: isAsk ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
            elide: Text.ElideRight
        }

        // Quantity
        DefaultText
        {
            Layout.preferredWidth: (parent.width / 100) * 30
            text: parseFloat(quantity).toFixed(6)
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        // Total
        DefaultText
        {
            Layout.preferredWidth: (parent.width / 100) * 30
            rightPadding: (is_mine) && (mouse_are.containsMouse || cancel_button.containsMouse) ? 30 : 0
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            text: parseFloat(total).toFixed(8)
            elide: Text.ElideRight

            Behavior on rightPadding { NumberAnimation { duration: 150 } }
        }
    }

    DefaultTooltip
    {
        visible: mouse_are.containsMouse && !enough_funds_to_pay_min_volume
        width: 300
        contentItem: DefaultText
        {
            text_value: qsTr("This order requires a minimum amount of %1 %2 <br>You don't have enough funds.<br> Your max balance after fees is: (%3)")
                            .arg(parseFloat(min_volume).toFixed(8))
                            .arg(isAsk ? API.app.trading_pg.market_pairs_mdl.right_selected_coin : API.app.trading_pg.market_pairs_mdl.left_selected_coin)
                            .arg(isAsk ? parseFloat(API.app.trading_pg.orderbook.rel_max_taker_vol.decimal).toFixed(8) : parseFloat(API.app.trading_pg.orderbook.base_max_taker_vol.decimal).toFixed(8))
            width: 300
        }
        delay: 200
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
                if(order_form.visible === false) {
                    order_form.visible = true
                }
                if(order_form.hidden === true) {
                    order_form.hidden = false
                    if(order_form.contentVisible === false) {
                        order_form.contentVisible = true
                    }
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

        color: cancel_button.containsMouse ? Qaterial.Colors.red : mouse_are.containsMouse? DexTheme.foregroundColor: Qaterial.Colors.red

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

    AnimatedRectangle
    {
        visible: !enough_funds_to_pay_min_volume && mouse_are.containsMouse
        color: DexTheme.dexBoxBackgroundColor
        anchors.fill: parent
        opacity: .3
    }
}
