import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import "../Components" as Dex
import "../Constants" as Dex

Dex.ComboBoxWithSearchBar
{
    id: control

    property var    currentItem: Dex.API.app.portfolio_pg.global_cfg_mdl.all_proxy.index(currentIndex, 0)
    property bool   showAssetStandards: false
    property var    assetStandards: availableNetworkStandards

    popupForceMaxHeight: true
    popupMaxHeight: 220

    model: showAssetStandards ? assetStandards : Dex.API.app.portfolio_pg.global_cfg_mdl.all_proxy
    textRole: showAssetStandards ? "" : "ticker"
    valueRole: showAssetStandards ? "" : "ticker"

    searchBar.visible: !showAssetStandards
    searchBar.searchModel: model

    delegate: ItemDelegate
    {
        id: _delegate

        visible: model.ticker !== "All"

        width: control.width
        height: visible ? 40 : 0
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
            id: _contentRow

            anchors.left: parent.left
            anchors.leftMargin: 13
            anchors.verticalCenter: parent.verticalCenter
            ticker: showAssetStandards ? assetStandards[currentIndex] : Dex.API.app.portfolio_pg.global_cfg_mdl.all_proxy.data(control.currentItem, Qt.UserRole + 1)
            name: showAssetStandards ? assetStandards[currentIndex] : Dex.API.app.portfolio_pg.global_cfg_mdl.all_proxy.data(control.currentItem, Qt.UserRole + 3)
            type: showAssetStandards ? assetStandards[currentIndex] : Dex.API.app.portfolio_pg.global_cfg_mdl.all_proxy.data(control.currentItem, Qt.UserRole + 9)
        }
    }

    onCurrentIndexChanged: {
        if (!showAssetStandards && currentIndex === 0 && searchBar.textField.text == "") {
                currentIndex = 1
        }
    }
    function reset_list() {
        if (showAssetStandards) currentIndex = 0; else { reset_search(); currentIndex = 1 }
    }

    function reset_search() {
        Dex.API.app.portfolio_pg.global_cfg_mdl.all_proxy.setFilterFixedString("");
        searchBar.textField.text = "";
    }
    onShowAssetStandardsChanged:  reset_list()
    onVisibleChanged: if (!visible) reset_list()
    Component.onDestruction:  reset_list()
    Component.onCompleted:  reset_list()
}
