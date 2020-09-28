import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import ".."

Item {
    id: root

    readonly property date default_min_date: new Date("2019-01-01")
    readonly property date default_max_date: new Date(new Date().setDate(new Date().getDate() + 1))

    property var list_model: API.app.orders_mdl
    property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
    property int page_index

    property alias title: order_list.title
    property alias empty_text: order_list.empty_text
    property alias items: order_list.items
    property alias showing_all_coins: show_all_coins.checked

    property bool is_history: false

    property string recover_funds_result: '{}'

    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === page_index
    }

    function applyDateFilter() {
        list_model_proxy.filter_minimum_date = show_all_coins.checked ? default_min_date : min_date.date
        list_model_proxy.filter_maximum_date = show_all_coins.checked ? default_max_date : max_date.date
    }

    function applyTickerFilter() {
        list_model_proxy.set_coin_filter(show_all_coins.checked ? "" : combo_base.currentValue + "/" + combo_rel.currentValue)
    }

    function applyFilter() {
        applyDateFilter()
        applyTickerFilter()
    }

    function reset() {  }

    function onOpened() {
        applyFilter()
        list_model_proxy.is_history = root.is_history
        API.app.refresh_orders_and_swaps()
    }

    function changeTicker(ticker) {
        combo_base.currentIndex = combo_base.model.map(c => c.value).indexOf(ticker)
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.height
        spacing: 15

        // Select coins row
        FloatingBackground {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            height: layout.height

            RowLayout {
                id: layout
                anchors.centerIn: parent

                DefaultSwitch {
                    id: show_all_coins
                    Layout.leftMargin: 15
                    text: API.app.settings_pg.empty_string + (qsTr("Disable Filters"))

                    checked: true
                    onCheckedChanged: applyFilter()
                }

                // Base
                DefaultImage {
                    Layout.leftMargin: 15
                    source: General.coinIcon(combo_base.currentValue)
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                DefaultComboBox {
                    id: combo_base
                    enabled: !show_all_coins.checked
                    Layout.preferredWidth: 120
                    Layout.topMargin: 10
                    Layout.bottomMargin: Layout.topMargin

                    textRole: "text"
                    valueRole: "value"

                    model: ([{ value: "", text: qsTr("All") }].concat(General.tickersOfCoins(General.all_coins)))
                    onCurrentValueChanged: applyTickerFilter()
                }

                // Swap button
                SwapIcon {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.rightMargin: 15
                    Layout.leftMargin: Layout.rightMargin

                    top_arrow_ticker: combo_base.currentValue
                    bottom_arrow_ticker: combo_rel.currentValue
                    hovered: swap_button.containsMouse

                    DefaultMouseArea {
                        id: swap_button
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            const base_idx = combo_base.currentIndex
                            combo_base.currentIndex = combo_rel.currentIndex
                            combo_rel.currentIndex = base_idx
                        }
                    }
                }

                DefaultComboBox {
                    id: combo_rel
                    enabled: !show_all_coins.checked
                    Layout.preferredWidth: 120
                    Layout.topMargin: combo_base.Layout.topMargin
                    Layout.bottomMargin: combo_base.Layout.bottomMargin

                    textRole: "text"
                    valueRole: "value"

                    model: combo_base.model
                    onCurrentValueChanged: applyTickerFilter()
                }

                // Rel
                DefaultImage {
                    Layout.rightMargin: 15
                    source: General.coinIcon(combo_rel.currentValue)
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                Qaterial.TextFieldDatePicker {
                    id: min_date
                    enabled: !show_all_coins.checked
                    title: API.app.settings_pg.empty_string + (qsTr("From"))
                    from: default_min_date
                    to: default_max_date
                    date: default_min_date
                    onAccepted: applyDateFilter()
                }

                Qaterial.TextFieldDatePicker {
                    id: max_date
                    enabled: min_date.enabled
                    title: API.app.settings_pg.empty_string + (qsTr("To"))
                    from: default_min_date
                    to: default_max_date
                    date: default_max_date
                    onAccepted: applyDateFilter()
                }

                // Cancel button
                DangerButton {
                    visible: !root.is_history
                    text: API.app.settings_pg.empty_string + (show_all_coins.checked ? qsTr("Cancel All Orders") : qsTr("Cancel Filtered Orders"))
                    enabled: list_model.length > 0
                    onClicked: {
                        if(show_all_coins.checked) API.app.trading_pg.cancel_all_orders()
                        else API.app.trading_pg.cancel_order(list_model_proxy.get_filtered_ids())
                    }
                }

                // Export button
                PrimaryButton {
                    visible: root.is_history
                    text: API.app.settings_pg.empty_string + (qsTr("Export CSV"))
                    enabled: list_model.length > 0
                    onClicked: {
                        // TODO: Export CSV
                        API.app.orders_mdl.orders_proxy_mdl.export_csv_visible_history("swap_history")
                    }
                }

            }
        }

        // Bottom part
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: parent.spacing

            OrderList {
                id: order_list
                items: list_model
            }
        }

        OrderModal {
            id: order_modal
        }
    }

    LogModal {
        id: recover_funds_modal

        header: API.app.settings_pg.empty_string + (qsTr("Recover Funds Result"))
        field.text: General.prettifyJSON(recover_funds_result)

        onClosed: recover_funds_result = "{}"
    }
}

