import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import AtomicDEX.CoinType 1.0

import "../Components"
import "../Constants"

BasicModal {
    id: root

    property var coin_cfg_model: API.app.portfolio_pg.global_cfg_mdl

    function setCheckState(checked) {
        coin_cfg_model.all_disabled_proxy.set_all_state(checked)
    }

    function filterCoins(text) {
        coin_cfg_model.all_disabled_proxy.setFilterFixedString(text === undefined ? input_coin_filter.text : text)
    }

    width: 500

    onOpened: {
        filterCoins()
        setCheckState(false)
        input_coin_filter.forceActiveFocus()
    }

    onClosed: filterCoins("")

    ModalContent {
        title: qsTr("Enable assets")

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

            onTextChanged: filterCoins()
        }

        DefaultCheckBox {
            text: qsTr("Select all assets")
            visible: list.visible

            // Handle updates
            property bool updated_from_backend: false
            property int checked_count: coin_cfg_model.checked_nb
            property int target_parent_state: coin_cfg_model.all_disabled_proxy.length === checked_count ? Qt.Checked :
                                                                checked_count > 0 ? Qt.PartiallyChecked : Qt.Unchecked
            onTarget_parent_stateChanged: {
                if(target_parent_state !== checkState) {
                    updated_from_backend = true
                    checkState = target_parent_state
                }
            }
            onCheckStateChanged: {
                // Avoid binding loop
                if(!updated_from_backend) setCheckState(checked)
                else updated_from_backend = false
            }
        }

        DefaultListView {
            id: list
            visible: coin_cfg_model.all_disabled_proxy.length > 0
            model: coin_cfg_model.all_disabled_proxy

            Layout.preferredHeight: 375
            Layout.fillWidth: true

            delegate: DefaultCheckBox {
                text: "         " + model.name + " (" + model.ticker + ")"

                leftPadding: indicator.width

                readonly property bool backend_checked: model.checked
                onBackend_checkedChanged: if(checked !== backend_checked) checked = backend_checked
                onCheckStateChanged: {
                    if(checked !== backend_checked)
                    {
                        var data_index = coin_cfg_model.all_disabled_proxy.index(index, 0)
                        if ((coin_cfg_model.all_disabled_proxy.setData(data_index, checked, Qt.UserRole + 11)) === false)
                        {
                            checked = false
                        }
                    }
                }

                // Icon
                DefaultImage {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: parent.leftPadding + 28
                    anchors.verticalCenter: parent.verticalCenter
                    source: General.coinIcon(model.ticker)
                    width: Style.textSize2
                }

                CoinTypeTag {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    type: model.type
                }
            }
        }

        // Info text
        DefaultText {
            visible: coin_cfg_model.all_disabled_proxy.length === 0

            text_value: qsTr("All assets are already enabled!")
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        DefaultRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            border.width: 0

            DefaultText {
                anchors.centerIn: parent
                text: qsTr("You can still enable %1 assets. Selected: %2.")
                        .arg(setting_modal.enableable_coins_count - API.app.portfolio_pg.portfolio_mdl.length)
                        .arg(coin_cfg_model.checked_nb)
            }
        }

        // Buttons
        footer: [
            DexButton {
                property var enableable_coins_count: setting_modal.enableable_coins_count;
                text: qsTr("Change assets limit")
                onClicked: setting_modal.open()
                textScale: API.app.settings_pg.lang=="fr"? 0.82 : 0.99
                onEnableable_coins_countChanged: setCheckState(false)
            },

            DexButton {
                text: qsTr("Close")
                textScale: API.app.settings_pg.lang=="fr"? 0.82 : 0.99
                Layout.fillWidth: true
                onClicked: root.close()
            },

            DexButton {
                visible: coin_cfg_model.length > 0
                enabled: coin_cfg_model.checked_nb > 0
                textScale: API.app.settings_pg.lang=="fr"? 0.82 : 0.99
                text: qsTr("Enable")
                Layout.fillWidth: true
                onClicked: {
                    API.app.enable_coins(coin_cfg_model.get_checked_coins())
                    setCheckState(false)
                    coin_cfg_model.checked_nb = 0
                    root.close()
                }
            }
        ]
    }
}
