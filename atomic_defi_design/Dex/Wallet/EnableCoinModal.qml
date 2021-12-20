//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! Project Imports
import Qaterial 1.0 as Qaterial

import AtomicDEX.CoinType 1.0
import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

BasicModal
{
    id: root

    property var coin_cfg_model: API.app.portfolio_pg.global_cfg_mdl

    function setCheckState(checked) 
    {
        coin_cfg_model.all_disabled_proxy.set_all_state(checked)
    }

    function filterCoins(text) 
    {
        coin_cfg_model.all_disabled_proxy.setFilterFixedString(text === undefined ? input_coin_filter.textField.text : text)
    }

    width: 676
    height: 720

    onOpened: 
    {
        filterCoins("");
        setCheckState(false);
        coin_cfg_model.checked_nb = 0;
        input_coin_filter.forceActiveFocus();
    }

    onClosed: 
    {
        filterCoins("");
        setCheckState(false);
        coin_cfg_model.checked_nb = 0;
    }

    ModalContent
    {
        title: qsTr("Enable assets")
        titleAlignment: Qt.AlignHCenter

        // Search input
        SearchField
        {
            id: input_coin_filter

            searchIconLeftMargin: 20
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.preferredWidth: 500
            Layout.preferredHeight: 44
            textField.placeholderText: qsTr("Search asset")

            textField.onTextChanged: filterCoins()
        }

        Item
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 5
            Layout.preferredWidth: 500
            Layout.preferredHeight: 25

            DexCheckBox
            {
                id: _selectAllCheckBox

                visible: list.visible
                checked: coin_cfg_model.checked_nb === setting_modal.enableable_coins_count - API.app.portfolio_pg.portfolio_mdl.length
                anchors.left: parent.left
                boxWidth: 20
                boxHeight: 20
                width: 20

                DefaultMouseArea
                {
                    anchors.fill: parent
                    onClicked: setCheckState(!parent.checked)
                }

                DefaultText
                {
                    anchors.left: parent.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Select all assets")
                }
            }
        }

        HorizontalLine { Layout.topMargin: 5; Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 500 }

        DefaultListView
        {
            id: list
            visible: coin_cfg_model.all_disabled_proxy.length > 0
            model: coin_cfg_model.all_disabled_proxy

            Layout.topMargin: -5
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 300
            Layout.preferredWidth: 515

            delegate: DexCheckBox
            {
                readonly property bool backend_checked: model.checked

                enabled: _selectAllCheckBox.checked ? checked : true
                boxWidth: 20
                boxHeight: 20
                spacing: 0

                onBackend_checkedChanged: if (checked !== backend_checked) checked = backend_checked
                onCheckStateChanged:
                {
                    if (checked !== backend_checked)
                    {
                        var data_index = coin_cfg_model.all_disabled_proxy.index(index, 0)
                        if ((coin_cfg_model.all_disabled_proxy.setData(data_index, checked, Qt.UserRole + 11)) === false)
                        {
                            checked = false
                        }
                    }
                }

                // Icon
                DefaultImage
                {
                    id: icon
                    anchors.left: parent.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    source: General.coinIcon(model.ticker)
                    width: 18
                    height: 18

                    DefaultText
                    {
                        anchors.left: parent.right
                        anchors.leftMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.name + " (" + model.ticker + ")"

                        CoinTypeTag
                        {
                            id: typeTag
                            anchors.left: parent.right
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            type: model.type
                        }

                        CoinTypeTag
                        {
                            anchors.left: typeTag.right
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: General.isIDO(model.ticker)
                            visible: enabled
                            type: "IDO"
                        }
                    }
                }
            }
        }

        Item
        {
            Layout.topMargin: 6
            Layout.preferredWidth: 500
            Layout.alignment: Qt.AlignHCenter

            DexLabel
            {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: coin_cfg_model.all_disabled_proxy.length > 0 ?
                          qsTr("You can still enable %1 assets. Selected: %2.")
                              .arg(setting_modal.enableable_coins_count - API.app.portfolio_pg.portfolio_mdl.length - coin_cfg_model.checked_nb)
                              .arg(coin_cfg_model.checked_nb) :
                          qsTr("All assets are already enabled!")

                color: Dex.CurrentTheme.textPlaceholderColor
            }
        }

        HorizontalLine { Layout.preferredWidth: 500; Layout.alignment: Qt.AlignHCenter }
        
        Item
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 500
            Layout.preferredHeight: 40

            DexTransparentButton
            {
                anchors.left: parent.left
                text: qsTr("Change assets limit")
                topPadding: 5
                bottomPadding: 5
                Layout.preferredHeight: 35
                onClicked:
                {
                    setting_modal.selectedMenuIndex = 0; 
                    setting_modal.open()
                }
            }
            DexTransparentButton
            {
                anchors.right: parent.right
                text: qsTr("Add a custom asset to the list")
                topPadding: 5
                bottomPadding: 5
                Layout.preferredHeight: 35
                iconSource: Qaterial.Icons.plus
                onClicked: {
                    root.close()
                    add_custom_coin_modal.open()
                }
            }
        }

        Item
        {
            Layout.preferredWidth: 500
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter

            DefaultButton
            {
                anchors.left: parent.left
                width: 199
                text: qsTr("Close")
                radius: 20
                onClicked: root.close()
            }

            DexGradientAppButton
            {
                anchors.right: parent.right
                width: 199
                visible: coin_cfg_model.length > 0
                enabled: coin_cfg_model.checked_nb > 0
                text: qsTr("Enable")
                radius: 20
                onClicked:
                {
                    API.app.enable_coins(coin_cfg_model.get_checked_coins())
                    setCheckState(false)
                    coin_cfg_model.checked_nb = 0
                    root.close()
                }
            }
        }
    }
}
