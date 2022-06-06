import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import "../Constants" as Dex

Dex.ComboBoxWithSearchBar
{
    id: control

    property var    currentItem: Dex.API.app.portfolio_pg.portfolio_mdl.portfolio_proxy_mdl.get(currentIndex)
    property bool   showAssetStandards: false
    property var    assetStandards: ["QRC-20", "ERC-20", "BEP-20", "Smart Chain"]

    popupForceMaxHeight: true
    popupMaxHeight: 265
    model: showAssetStandards ? assetStandards : Dex.API.app.portfolio_pg.portfolio_mdl.portfolio_proxy_mdl
    textRole: showAssetStandards ? "" : "ticker"

    delegate: ItemDelegate
    {
        id: _delegate

        width: control.width
        height: 40
        highlighted: control.highlightedIndex === index

        contentItem: AssetRow
        {
            ticker: showAssetStandards ? modelData : model.ticker
            name: showAssetStandards ? modelData : model.name
            type: showAssetStandards ? modelData : model.type
        }

        background: Dex.Rectangle
        {
            anchors.fill: _delegate
            color: _delegate.highlighted ? Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor : Dex.CurrentTheme.comboBoxBackgroundColor
        }
    }

    contentItem: Item
    {
        AssetRow
        {
            anchors.left: parent.left
            anchors.leftMargin: 13
            anchors.verticalCenter: parent.verticalCenter
            ticker: showAssetStandards ? assetStandards[currentIndex] : control.currentItem.ticker
            name: showAssetStandards ? assetStandards[currentIndex] : control.currentItem.name
            type: showAssetStandards ? assetStandards[currentIndex] : control.currentItem.type
        }
    }

    onSearchBarTextChanged: Dex.API.app.portfolio_pg.portfolio_mdl.portfolio_proxy_mdl.setFilterFixedString(patternStr)
    Component.onDestruction: Dex.API.app.portfolio_pg.portfolio_mdl.portfolio_proxy_mdl.setFilterFixedString("")
}
