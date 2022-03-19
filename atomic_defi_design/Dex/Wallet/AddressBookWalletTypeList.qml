import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

Qaterial.Expandable
{
    id: _root

    property string title

    property string type_title
    property string type: ""
    property string typeIcon: type

    property var model

    header: Qaterial.ItemDelegate
    {
        id: _header

        icon.source: General.image_path + "arrow_down.svg"

        onClicked: () => _root.expanded = !_root.expanded

        TitleText
        {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 75
            text: title
            font.bold: true
        }
    }

    delegate: Column
    {
        AddressBookWalletTypeListRow
        {
            enabled: type !== ""
            visible: type !== ""

            icon_source: General.coinTypeIcon(typeIcon)

            width: _root.width

            name: type_title
            ticker: type_title

            onClicked: onTypeSelect(type)
        }

        Repeater
        {
            model: _root.model

            delegate: AddressBookWalletTypeListRow
            {
                width: _root.width

                name: model.name
                ticker: model.ticker

                onClicked:
                {
                    if (!API.app.portfolio_pg.global_cfg_mdl.get_coin_info(model.ticker).is_enabled)
                        _tooltip.open()
                    else
                        onTypeSelect(ticker)
                }

                DefaultTooltip
                {
                    id: _tooltip

                    width: 250
                    anchors.centerIn: parent

                    dim: true
                    modal: true
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    contentItem: DexLabelUnlinked
                    {
                        text_value: qsTr("%1 is not enabled - You need to enable it before adding an address. Enable it ?<br><a href='#'>Yes</a> - <a href='#no'>No</a>").arg(model.ticker)
                        wrapMode: DefaultText.Wrap
                        width: 350
                        onLinkActivated:
                        {
                            if (link === "#no") _tooltip.close()
                            else
                            {
                                if (API.app.enable_coins([model.ticker]) === false)
                                    cannot_enable_coin_modal.open()
                                else
                                {
                                    color = Dex.CurrentTheme.buttonTextDisabledColor
                                    opacity = 0.8
                                    _coinIsEnabling.visible = true
                                 }
                            }
                        }
                    }

                    BusyIndicator
                    {
                        id: _coinIsEnabling

                        visible: false
                        enabled: visible
                        anchors.fill: parent

                        Connections
                        {
                            target: API.app.portfolio_pg.global_cfg_mdl.all_disabled_proxy

                            function onLengthChanged()
                            {
                                _tooltip.close()
                            }
                         }
                    }

                    ModalLoader
                    {
                        property string coin_to_enable_ticker: model.ticker
                        id: cannot_enable_coin_modal
                        sourceComponent: CannotEnableCoinModal { coin_to_enable_ticker: cannot_enable_coin_modal.coin_to_enable_ticker }
                    }

                    delay: 200
                }
            }
        }
    }
}
