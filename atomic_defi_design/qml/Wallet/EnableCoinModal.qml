import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

BasicModal {
    id: root

    width: 400

    property var selected_to_enable: ({})

    function resetList() {
        // selected_to_enable = {}

        // Modifying selected_to_enable creates a binding loop
        // Have to check and then uncheck to affect all child checkboxes
        coins_utxo.parent_box.checkState = Qt.Checked
        coins_utxo.parent_box.checkState = Qt.Unchecked
        coins_smartchains.parent_box.checkState = Qt.Checked
        coins_smartchains.parent_box.checkState = Qt.Unchecked
        coins_erc.parent_box.checkState = Qt.Checked
        coins_erc.parent_box.checkState = Qt.Unchecked
        coins_qrc.parent_box.checkState = Qt.Checked
        coins_qrc.parent_box.checkState = Qt.Unchecked
    }

    function reset() {
        resetList()
        input_coin_filter.text = ""
    }

    onClosed: {
        reset()
    }

    function prepareAndOpen() {
        reset()
        root.open()
    }

    function markToEnable(ticker, enabled) {
        if(enabled) selected_to_enable[ticker] = true
        else delete selected_to_enable[ticker]

        selected_to_enable = selected_to_enable
    }

    function enableCoins() {
        const coins_to_enable = Object.keys(selected_to_enable)
        console.log("QML enable_coins:", JSON.stringify(coins_to_enable))
        API.app.enable_coins(coins_to_enable)
        reset()
        root.close()
    }

    ModalContent {
        title: API.app.settings_pg.empty_string + (qsTr("Enable coins"))

        // Search input
        DefaultTextField {
            id: input_coin_filter

            Layout.fillWidth: true
            placeholderText: API.app.settings_pg.empty_string + (qsTr("Search"))
            selectByMouse: true
        }

        DefaultFlickable {
            id: flickable
            visible: API.app.enableable_coins.length > 0

            height: 450
            Layout.fillWidth: true

            contentWidth: col.width
            contentHeight: col.height

            Column {
                id: col

                CoinList {
                    id: coins_utxo
                    group_title: API.app.settings_pg.empty_string + qsTr("Select all UTXO coins")
                    model: General.filterCoins(API.app.enableable_coins, input_coin_filter.text, "UTXO")
                }

                CoinList {
                    id: coins_smartchains
                    group_title: API.app.settings_pg.empty_string + qsTr("Select all SmartChains")
                    model: General.filterCoins(API.app.enableable_coins, input_coin_filter.text, "Smart Chain")
                }

                CoinList {
                    id: coins_erc
                    group_title: API.app.settings_pg.empty_string + qsTr("Select all ERC tokens")
                    model: General.filterCoins(API.app.enableable_coins, input_coin_filter.text, "ERC-20")
                }

                CoinList {
                    id: coins_qrc
                    group_title: API.app.settings_pg.empty_string + qsTr("Select all QRC tokens")
                    model: General.filterCoins(API.app.enableable_coins, input_coin_filter.text, "QRC-20")
                }
            }
        }


        // Info text
        DefaultText {
            visible: API.app.enableable_coins.length === 0

            text_value: API.app.settings_pg.empty_string + (qsTr("All coins are already enabled!"))
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.app.settings_pg.empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            },

            PrimaryButton {
                visible: API.app.enableable_coins.length > 0
                enabled: Object.keys(selected_to_enable).length > 0
                text: API.app.settings_pg.empty_string + (qsTr("Enable"))
                Layout.fillWidth: true
                onClicked: enableCoins()
            }
        ]
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
