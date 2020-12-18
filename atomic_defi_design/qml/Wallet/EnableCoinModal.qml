import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import AtomicDEX.CoinType 1.0

import "../Components"
import "../Constants"

BasicModal {
    property var coin_cfg_model: API.app.portfolio_pg.global_cfg_mdl
    property bool should_clear: coin_cfg_model.all_proxy.length === coin_cfg_model.checked_nb

    function uncheck_all() {
        // Have to check and then uncheck to affect all child checkboxes

        coins_qrc20.parent_box.checkState = Qt.Checked
        coins_qrc20.parent_box.checkState = Qt.Unchecked

        coins_erc20.parent_box.checkState = Qt.Checked
        coins_erc20.parent_box.checkState = Qt.Unchecked

        coins_smartchains.parent_box.checkState = Qt.Checked
        coins_smartchains.parent_box.checkState = Qt.Unchecked

        coins_utxo.parent_box.checkState = Qt.Checked
        coins_utxo.parent_box.checkState = Qt.Unchecked
    }

    function check_all() {
        coins_qrc20.parent_box.checkState = Qt.Checked
        coins_erc20.parent_box.checkState = Qt.Checked
        coins_smartchains.parent_box.checkState = Qt.Checked
        coins_utxo.parent_box.checkState = Qt.Checked
    }

    function filter_coins() {
        coin_cfg_model.qrc20_proxy.setFilterFixedString(input_coin_filter.text)
        coin_cfg_model.erc20_proxy.setFilterFixedString(input_coin_filter.text)
        coin_cfg_model.smartchains_proxy.setFilterFixedString(input_coin_filter.text)
        coin_cfg_model.utxo_proxy.setFilterFixedString(input_coin_filter.text)
    }

    id: root

    width: 500

    onOpened: {
        uncheck_all()
        filter_coins()
        input_coin_filter.forceActiveFocus()
    }

    ModalContent {
        title: qsTr("Enable assets")

        DefaultButton {
            Layout.fillWidth: true
            text: should_clear ? qsTr("Clear All Selection") : qsTr("Enable All Assets")
            visible: coin_cfg_model.length > 0
            onClicked: {
                if (should_clear) {
                    uncheck_all()
                }
                else {
                    check_all()
                }
            }
        }

        DefaultButton {
            Layout.fillWidth: true
            text: qsTr("Add a custom asset to the list")
            onClicked: {
                root.close()
                add_custom_coin_modal.open()
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        // Search input
        DefaultTextField {
            id: input_coin_filter

            Layout.fillWidth: true
            placeholderText: qsTr("Search")

            onTextChanged: filter_coins()
        }

        DefaultFlickable {
            id: flickable
            visible: coin_cfg_model.all_proxy.length > 0

            height: 375
            Layout.fillWidth: true

            contentWidth: col.width
            contentHeight: col.height

            Column {
                id: col

                CoinList {
                    id: coins_qrc20
                    group_title: qsTr("Select all QRC20 assets")
                    model: coin_cfg_model.qrc20_proxy
                }

                CoinList {
                    id: coins_smartchains
                    group_title: qsTr("Select all SmartChains")
                    model: coin_cfg_model.smartchains_proxy
                }

                CoinList {
                    id: coins_erc20
                    group_title: qsTr("Select all ERC20 assets")
                    model:coin_cfg_model.erc20_proxy
                }

                CoinList {
                    id: coins_utxo
                    group_title: qsTr("Select all UTXO assets")
                    model: coin_cfg_model.utxo_proxy
                }
            }
        }

        // Info text
        DefaultText {
            visible: coin_cfg_model.all_proxy.length === 0

            text_value: qsTr("All assets are already enabled!")
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            },

            PrimaryButton {
                visible: coin_cfg_model.length > 0
                enabled: coin_cfg_model.checked_nb > 0
                text: qsTr("Enable")
                Layout.fillWidth: true
                onClicked: {
                    const checked_coins = coin_cfg_model.get_checked_coins()

                    uncheck_all()
                    API.app.enable_coins(checked_coins)
                    coin_cfg_model.checked_nb = 0
                    root.close()
                }
            }
        ]
    }
}
