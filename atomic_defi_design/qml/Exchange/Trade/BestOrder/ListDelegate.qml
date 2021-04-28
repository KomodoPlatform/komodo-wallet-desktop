import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15


import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

Item {
    id: _control
    property bool coinEnable: API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled
    property var isAsk: {
        if(parseInt(cex_rates)>0){
            false
        }else if(parseInt(cex_rates)<0) {
            true
        }else {
            undefined
        }
    }
    width: visible? list.width : 0
    height: 36


    AnimatedRectangle {
        visible: mouse_are.containsMouse
        width: parent.width
        height: parent.height
        color: theme.foregroundColor
        opacity: 0.1
    }

    RowLayout {
        id: row
        width:  parent.width - 30
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Row {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 140
            leftPadding: -10
            spacing: 5
            Image {
                source: General.coinIcon(coin)
                width: 20
                height: 20
                smooth: true
                antialiasing: true
                opacity: !_control.coinEnable? .1 : 1
                anchors.verticalCenter: parent.verticalCenter
            }
            DefaultText {
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 2
                text: send + " " + atomic_qt_utilities.retrieve_main_ticker(coin)
                font.pixelSize: Style.textSizeSmall1

            }
        }
        DefaultTooltip {
            id: _tooltip
            dim: true
            modal: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            width: 250
            contentItem: DexLabelUnlinked {
                text_value: qsTr(" %1 is not Enabled - do you want to enable it to be able to select %2 best orders ?<br><a href='#'>Yes</a> -<a href='#no'>No</a>").arg(coin).arg(coin)
                wrapMode: DefaultText.Wrap
                width: 250
                onLinkActivated: {
                    if(link==="#no") {
                        _tooltip.close()
                    }else {
                        API.app.enable_coins([coin])
                        _control.coinEnable = true
                        _tooltip.close()
                    }
                }
            }
            delay: 200
        }

        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 70
            text: price_fiat+API.app.settings_pg.current_fiat_sign
            font: theme.textType.caption
            horizontalAlignment: Label.AlignRight
            opacity: 1

        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true


        }
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            
            text: cex_rates==="0"? "N/A" : parseFloat(cex_rates)>0? "+"+parseFloat(cex_rates).toFixed(2)+"%" : parseFloat(cex_rates).toFixed(2)+"%"


            Behavior on rightPadding {
                NumberAnimation {
                    duration: 150
                }
            }

            color:cex_rates==="0"? Qt.darker(theme.foregroundColor) : parseFloat(cex_rates)<0? Style.colorGreen : Style.colorRed
            horizontalAlignment: Label.AlignRight
            font.pixelSize: Style.textSizeSmall1
            opacity: 1

        }
    }


    DefaultMouseArea {
        id: mouse_are
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if(!API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled){
                _tooltip.open()
            }else {
                API.app.trading_pg.orderbook.select_best_order(uuid)
            }
            
            //if(is_mine) return
            //isAsk? selectOrder(true, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume) : selectOrder(false, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume)
        }
    }
    HorizontalLine {
        width: parent.width
    }

}
