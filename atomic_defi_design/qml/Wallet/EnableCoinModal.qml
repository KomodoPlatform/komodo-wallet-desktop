import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import AtomicDEX.CoinType 1.0

import "../Components"
import "../Constants"

BasicModal {
    id: root

    property var coin_cfg_model: API.app.portfolio_pg.global_cfg_mdl
    property bool should_clear: coin_cfg_model.all_disabled_proxy.length === coin_cfg_model.checked_nb
    onShould_clearChanged: {
        if(should_clear !== parent_checkbox.checked) {
            parent_checkbox.updated_from_backend = true
            parent_checkbox.checked = should_clear
        }
    }

    function uncheck_all() {
        coin_cfg_model.all_disabled_proxy.set_all_state(false)
    }

    function check_all() {
        coin_cfg_model.all_disabled_proxy.set_all_state(true)
    }

    function filter_coins() {
        coin_cfg_model.all_disabled_proxy.setFilterFixedString(input_coin_filter.text)
    }

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

        DefaultCheckBox {
            id: parent_checkbox
            property bool updated_from_backend: false

            text: qsTr("Select all assets")
            visible: list.visible
            onCheckStateChanged: {
                // Avoid binding loop
                if(!updated_from_backend) {
                    if (checked) check_all()
                    else {
                        uncheck_all()
                    }
                }
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
                onBackend_checkedChanged: {
                    if(checked !== backend_checked) checked = backend_checked
                }
                onCheckStateChanged: {
                    if(checked !== backend_checked) model.checked = checked
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
