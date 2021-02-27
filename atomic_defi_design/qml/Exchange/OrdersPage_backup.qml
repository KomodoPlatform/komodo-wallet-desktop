import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import ".."

Item {
    id: root

    readonly property date default_min_date: new Date("2019-01-01")
    readonly property date default_max_date: new Date(new Date().setDate(new Date().getDate() + 30))

    property var list_model: API.app.orders_mdl
    property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
    property int page_index

    property alias title: order_list.title
    property alias empty_text: order_list.empty_text
    property alias items: order_list.items

    property bool is_history: false

    property string recover_funds_result: '{}'

    function onRecoverFunds(order_id) {
        const result = API.app.recover_fund(order_id)
        console.log("Refund result: ", result)
        recover_funds_result = result
        recover_funds_modal.open()
    }

//    function inCurrentPage() {
//        return  exchange.inCurrentPage() &&
//                exchange.current_page === page_index
//    }

    function applyDateFilter() {
        list_model_proxy.filter_minimum_date = min_date.date

        if(max_date.date < min_date.date)
            max_date.date = min_date.date

        list_model_proxy.filter_maximum_date = max_date.date
    }

    function applyTickerFilter() {
        list_model_proxy.set_coin_filter(combo_base.currentValue + "/" + combo_rel.currentValue)
    }

    function applyFilter() {
        applyDateFilter()
        applyTickerFilter()
    }

    Component.onCompleted: {
        list_model_proxy.is_history = root.is_history
        applyFilter()
        list_model_proxy.apply_all_filtering()
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

                // Base
                DefaultImage {
                    source: General.coinIcon(combo_base.currentText)
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                DefaultComboBox {
                    id: combo_base
                    Layout.preferredWidth: 120
                    Layout.topMargin: 10
                    Layout.bottomMargin: Layout.topMargin

                    textRole: "ticker"
                    valueRole: "ticker"

                    model: API.app.portfolio_pg.global_cfg_mdl.all_proxy
                    onCurrentValueChanged: applyFilter()
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
                    Layout.preferredWidth: 120
                    Layout.topMargin: combo_base.Layout.topMargin
                    Layout.bottomMargin: combo_base.Layout.bottomMargin

                    textRole: "ticker"
                    valueRole: "ticker"

                    model: combo_base.model
                    onCurrentValueChanged: applyFilter()
                }

                // Rel
                DefaultImage {
                    Layout.rightMargin: 15
                    source: combo_rel.currentText === "All" ? "" : General.coinIcon(combo_rel.currentText)
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                Qaterial.TextFieldDatePicker {
                    id: min_date
                    title: qsTr("From")
                    from: default_min_date
                    to: default_max_date
                    date: default_min_date
                    onAccepted: applyDateFilter()
                    background: FloatingBackground {

                    }
                }

                Qaterial.TextFieldDatePicker {
                    id: max_date
                    enabled: min_date.enabled
                    title: qsTr("To")
                    from: min_date.date
                    to: default_max_date
                    date: default_max_date
                    onAccepted: applyDateFilter()
                }

                // Apply Filter Button
                PrimaryButton {
                    visible: root.is_history
                    Layout.leftMargin: 30
                    text: qsTr("Apply Filter")
                    enabled: list_model_proxy.can_i_apply_filtering
                    onClicked: list_model_proxy.apply_all_filtering()
                }

                // Cancel button
                DangerButton {
                    visible: !root.is_history
                    Layout.leftMargin: 30
                    text: qsTr("Cancel Displayed Orders")
                    enabled: list_model.length > 0
                    onClicked: API.app.trading_pg.cancel_order(list_model_proxy.get_filtered_ids())
                }

                // Export button
                PrimaryButton {
                    Layout.leftMargin: 20
                    visible: root.is_history
                    text: qsTr("Export CSV")
                    enabled: list_model.length > 0
                    onClicked: {
                        export_csv_dialog.folder = General.os_file_prefix + API.app.settings_pg.get_export_folder()
                        export_csv_dialog.open()
                    }
                }

                FileDialog {
                    id: export_csv_dialog

                    title: qsTr("Please choose the CSV export name and location")
                    selectMultiple: false
                    selectExisting: false
                    selectFolder: false

                    defaultSuffix: "csv"
                    nameFilters: [ "CSV files (*.csv)", "All files (*)" ]

                    onAccepted: {
                        const path = fileUrl.toString()

                        // Export
                        console.log("Exporting to CSV: " + path)
                        API.app.exporter_service.export_swaps_history_to_csv(path.replace(General.os_file_prefix, ""))

                        // Open the save folder
                        const folder_path = path.substring(0, path.lastIndexOf("/"))
                        Qt.openUrlExternally(folder_path)
                    }
                    onRejected: {
                        console.log("CSV export cancelled")
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
                is_history: root.is_history
            }
        }

        ModalLoader {
            id: order_modal
            sourceComponent: OrderModal {}
        }
    }

    ModalLoader {
        id: recover_funds_modal
        sourceComponent: LogModal {
            header: qsTr("Recover Funds Result")
            field.text: General.prettifyJSON(recover_funds_result)

            onClosed: recover_funds_result = "{}"
        }
    }
}

