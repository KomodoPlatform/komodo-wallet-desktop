import QtQuick 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"

BasicModal {
    id: root

    readonly property var glb_coins_cfg_mdl: API.app.portfolio_pg.global_cfg_mdl
    property alias selected_wallet_type : wallet_list.selected_wallet_type

    function resetModal() {
        searchbar.text = ""
        filterWallets(searchbar.text)
    }

    function filterWallets(text) {
        glb_coins_cfg_mdl.all_qrc20_proxy.setFilterFixedString(text)
        glb_coins_cfg_mdl.all_erc20_proxy.setFilterFixedString(text)
        glb_coins_cfg_mdl.all_smartchains_proxy.setFilterFixedString(text)
        glb_coins_cfg_mdl.all_utxo_proxy.setFilterFixedString(text)

        // Expands type lists if searchbar is not empty
        qrc20_expandable.expanded = text !== ""
        erc20_expandable.expanded = text !== ""
        sc_expandable.expanded = text !== ""
        utxo_expandable.expanded = text !== ""
    }

    function onTypeSelect(type_or_ticker) {
        selected_wallet_type = type_or_ticker
        close()
    }

    onOpened: searchbar.forceActiveFocus()
    onClosed: resetModal()

    width: 400

    ModalContent {
        id: wallet_list

        property string selected_wallet_type: ""

        title: qsTr("Select wallet type")

        // Search input
        DefaultTextField {
            Layout.rightMargin: 10
            id: searchbar

            Layout.fillWidth: true
            placeholderText: qsTr("Search")

            onTextChanged: filterWallets(text)
        }

        AddressBookWalletTypeList {
            id: qrc20_expandable
            Layout.rightMargin: 10
            Layout.fillWidth: true
            title: "QRC-20 coins"
            type_title: "QRC-20"
            type: "QRC-20"
            model: glb_coins_cfg_mdl.all_qrc20_proxy
        }

        AddressBookWalletTypeList {
            id: erc20_expandable
            Layout.rightMargin: 10
            Layout.fillWidth: true
            title: "ERC-20 coins"
            type_title: "ERC-20"
            type: "ERC-20"
            model: glb_coins_cfg_mdl.all_erc20_proxy
        }

        AddressBookWalletTypeList {
            id: sc_expandable
            Layout.rightMargin: 10
            Layout.fillWidth: true
            title: "Smart Chain coins"
            type_title: "Smart Chain"
            type: "Smart Chain"
            model: glb_coins_cfg_mdl.all_smartchains_proxy
        }

        AddressBookWalletTypeList {
            id: utxo_expandable
            Layout.rightMargin: 10
            Layout.fillWidth: true
            title: "UTXO coins"
            type_title: "UTXO"
            model: glb_coins_cfg_mdl.all_utxo_proxy
        }
    }
}
