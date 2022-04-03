import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"
import Dex.Themes 1.0 as Dex
import AtomicDEX.MarketMode 1.0
import App 1.0 as App

Item
{
    id: _control

    property bool coinEnable: API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled
    property var isAsk:
    {
        if (parseInt(cex_rates) > 0)
        {
            false
        }
        else if(parseInt(cex_rates) < 0)
        {
            true
        }
        else
        {
            undefined
        }
    }

    AnimatedRectangle
    {
        visible: mouse_are.containsMouse
        width: parent.width
        height: parent.height
        color: Dex.CurrentTheme.foregroundColor
        opacity: 0.1
    }

    Row
    {
        id: row
        width: parent.width
        height: parent.height
        spacing: 0

        Row
        {
            width: parent.width * youGetColumnWidth
            height: parent.height
            spacing: 8

            DefaultImage
            {
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                Layout.alignment: Qt.AlignVCenter
                source: General.coinIcon(coin)
                smooth: true
                antialiasing: true
                opacity: !_control.coinEnable? .1 : 1
            }

            DefaultText
            {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * 0.8
                text: send + " " + coin
                font.family: App.DexTypo.fontFamily
                font.pixelSize: 12
            }
        }

        DefaultText
        {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * fiatPriceColumnWidth
            text: price_fiat + API.app.settings_pg.current_fiat_sign
            font.family: App.DexTypo.fontFamily
            font.pixelSize: 12
        }

        DefaultText
        {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * cexRateColumnWidth
            
            text: cex_rates === "0" ? "N/A" :
                                      parseFloat(cex_rates) > 0 ? "+" + parseFloat(cex_rates).toFixed(2) + "%" :
                                                                  parseFloat(cex_rates).toFixed(2) + "%"
            font.family: App.DexTypo.fontFamily
            font.pixelSize: 12

            color: cex_rates === "0" ? Qt.darker(Dex.CurrentTheme.foregroundColor) :
                                       parseFloat(cex_rates) < 0 ? Dex.CurrentTheme.okColor :
                                                                   Dex.CurrentTheme.noColor

            Behavior on rightPadding
            {
                NumberAnimation
                {
                    duration: 150
                }
            }
        }
    }

    DefaultTooltip
    {
        id: _tooltip
        dim: true
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        width: 250
        contentItem: DexLabelUnlinked
        {
            text_value: qsTr(" %1 is not enabled - Do you want to enable it to be able to select %2 best orders ?<br><a href='#'>Yes</a> - <a href='#no'>No</a>").arg(coin).arg(coin)
            wrapMode: DefaultText.Wrap
            width: 250
            onLinkActivated:
            {
                if (link === "#no")
                {
                    _tooltip.close();
                }
                else
                {
                    if (API.app.enable_coins([coin]) === true)
                    {
                        _control.coinEnable = true;
                        _tooltip.close();
                    }
                    else {
                        cannot_enable_coin_modal.open();
                    }
                }
            }

            ModalLoader {
                property string coin_to_enable_ticker: coin
                id: cannot_enable_coin_modal
                sourceComponent: CannotEnableCoinModal { coin_to_enable_ticker: cannot_enable_coin_modal.coin_to_enable_ticker }
            }
        }
        delay: 200
    }

    DefaultMouseArea
    {
        id: mouse_are
        anchors.fill: parent
        hoverEnabled: true
        onClicked:
        {
            if (!API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled)
            {
                _tooltip.open()
            }
            else
            {
                if (API.app.trading_pg.market_mode == MarketMode.Buy)
                {
                    app.pairChanged(rel_ticker, coin)
                }
                else
                {
                    app.pairChanged(base_ticker, coin)
                }
                API.app.trading_pg.orderbook.select_best_order(uuid)
            }
        }
    }
}
