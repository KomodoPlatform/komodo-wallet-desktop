import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15


import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants" as Constants
import Dex.Themes 1.0 as Dex

import App 1.0 as App

Item
{
    id: _control

    property bool coinEnable: Constants.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled
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

    width: visible? list.width : 0
    height: 36

    AnimatedRectangle
    {
        visible: mouse_are.containsMouse
        width: parent.width
        height: parent.height
        color: Dex.CurrentTheme.foregroundColor
        opacity: 0.1
    }

    RowLayout
    {
        id: row
        width:  parent.width - 30
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Image
        {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            source: Constants.General.coinIcon(coin)
            smooth: true
            antialiasing: true
            opacity: !_control.coinEnable? .1 : 1
        }
        DefaultText
        {
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignVCenter
            text: send + " " + atomic_qt_utilities.retrieve_main_ticker(coin)
            font.family: App.DexTypo.fontFamily
            font.pixelSize: 12
        }

        DefaultText
        {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 60
            text: price_fiat + Constants.API.app.settings_pg.current_fiat_sign
            font.family: App.DexTypo.fontFamily
            font.pixelSize: 12
        }

        DefaultText
        {
            Layout.alignment: Qt.AlignVCenter
            
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
                    if (Constants.API.app.enable_coins([coin]) === true)
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
            if (!Constants.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(coin).is_enabled)
            {
                _tooltip.open()
            }
            else
            {
                app.pairChanged(base_ticker, coin)
                Constants.API.app.trading_pg.orderbook.select_best_order(uuid)
            }
        }
    }

    HorizontalLine
    {
        width: parent.width
        opacity: .4
    }

}
