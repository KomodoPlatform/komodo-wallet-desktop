import QtQuick 2.12
import QtQuick.Layouts 1.3

import Dex.Components 1.0 as Dex
import Dex.Themes 1.0 as Dex
import "../Constants" as Dex

Dex.MultipageModal
{
    id: root

    property string standard

    signal selected(var assetTicker)

    width: 560

    Dex.MultipageModalContent
    {
        titleText: qsTr("Choose a valid ") + standard + qsTr(" asset")

        Dex.ListView
        {
            id: list

            Layout.fillWidth: true
            Layout.maximumHeight: 500

            model: standard == "QRC-20" ? Dex.API.app.portfolio_pg.global_cfg_mdl.all_qrc20_proxy :
                   standard == "ERC-20" ? Dex.API.app.portfolio_pg.global_cfg_mdl.all_erc20_proxy :
                   standard == "BEP-20" ? Dex.API.app.portfolio_pg.global_cfg_mdl.all_bep20_proxy :
                                          Dex.API.app.portfolio_pg.global_cfg_mdl.all_smartchains_proxy

            spacing: 8

            delegate: Item
            {
                width: list.width
                height: 40

                Dex.Rectangle
                {
                    anchors.fill: parent
                    color: mouseArea.containsMouse ? Dex.CurrentTheme.buttonColorHovered : "transparent"
                }

                AssetRow
                {
                    id: assetRow
                    height: parent.height
                    ticker: model.ticker
                    type: model.type
                    name: model.name
                }

                Dex.Text
                {
                    visible: !model.enabled
                    anchors.left: assetRow.right
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Disabled")
                    color: Dex.CurrentTheme.noColor
                    font: Dex.DexTypo.caption
                }

                Dex.MouseArea
                {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.selected(model.ticker)
                }
            }
        }
    }
}
