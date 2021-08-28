import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1

import Qaterial 1.0 as Qaterial

import App 1.0

import "../../../Components"
import "../../.."

Item {
    id: root

    readonly property date default_min_date: new Date("2019-01-01")
    readonly property date default_max_date: new Date(new Date().setDate(new Date().getDate() + 30))

    property
    var list_model: API.app.orders_mdl
    property
    var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
    property int page_index

    property alias title: order_list.title
    //property alias empty_text: order_list.empty_text
    property alias items: order_list.items

    property bool is_history: false

    function update() {
        reset()
        if (combo_base.currentTicker !== "All" | combo_rel.currentTicker !== "All") {
            buttonDelay.start()
        }
    }

    function reset() {
        list_model_proxy.is_history = !is_history
        applyFilter()
        list_model_proxy.apply_all_filtering()
        list_model_proxy.is_history = is_history
    }

    Component.onDestruction: reset()

    Timer {
        id: buttonDelay
        interval: 200
        onTriggered: {
            applyFilter()
            list_model_proxy.apply_all_filtering()
        }
    }

    function applyDateFilter() {
        list_model_proxy.filter_minimum_date = min_date.date

        if (max_date.date < min_date.date)
            max_date.date = min_date.date

        list_model_proxy.filter_maximum_date = max_date.date
    }

    function applyTickerFilter() {
        list_model_proxy.set_coin_filter(combo_base.currentValue + "/" + combo_rel.currentValue)
    }

    function applyTickerFilter2(ticker1, ticker2) {
        list_model_proxy.set_coin_filter(ticker1 + "/" + ticker2)
    }

    function applyFilter() {
        applyDateFilter()
        applyTickerFilter2(combo_base.currentTicker, combo_rel.currentTicker)
    }

    Component.onCompleted: {
        list_model_proxy.is_history = root.is_history
        applyFilter()
        list_model_proxy.apply_all_filtering()
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        anchors.fill: parent
        anchors.bottomMargin: is_history ? 0 : 10
        spacing: 15

        // Bottom part
        Item {
            id: orders_settings
            property bool displaySetting: false
            Layout.fillWidth: true
            Layout.preferredHeight: displaySetting ? 80 : 30
            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 150
                }
            }

            Rectangle {
                width: parent.width
                height: orders_settings.displaySetting ? 50 : 10
                Behavior on height {
                    NumberAnimation {
                        duration: 150
                    }
                }
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -15
                visible: false
                color: Style.colorTheme5
            }

            Row {
                x: 5
                y: 0
                spacing: 5
                Qaterial.OutlineButton {
                    icon.source: Qaterial.Icons.filter
                    text: qsTr("Filter")
                    foregroundColor: Style.colorWhite5
                    anchors.verticalCenter: parent.verticalCenter
                    outlinedColor: Style.colorTheme5
                    onClicked: orders_settings.displaySetting = !orders_settings.displaySetting
                }

                DexLabel {
                    opacity: .4
                    visible: !orders_settings.displaySetting
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Filter") + ": %1 / %2 <br> %3: %4 - %5"
                        .arg(combo_base.currentTicker)
                        .arg(combo_rel.currentTicker)
                        .arg(qsTr("Date"))
                        .arg(min_date.date.toLocaleDateString(Locale.ShortFormat, "yyyy-MM-dd"))
                        .arg(max_date.date.toLocaleDateString(Locale.ShortFormat, "yyyy-MM-dd"))
                }

                Qaterial.OutlineButton {
                    visible: root.is_history && orders_settings.displaySetting
                    foregroundColor: Style.colorWhite5
                    outlinedColor: Style.colorTheme5
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Export CSV")
                    enabled: list_model.length > 0
                    onClicked: {
                        export_csv_dialog.folder = General.os_file_prefix + API.app.settings_pg.get_export_folder()
                        export_csv_dialog.open()
                    }
                }
            }

            Row {
                anchors.right: parent.right
                y: 0
                rightPadding: 5
                Qaterial.OutlineButton {
                    visible: root.is_history & orders_settings.displaySetting
                    Layout.leftMargin: 30
                    text: qsTr("Apply Filter")
                    foregroundColor: enabled ? Style.colorGreen2 : Style.colorTheme5
                    outlinedColor: enabled ? Style.colorGreen2 : Style.colorTheme5
                    enabled: list_model_proxy.can_i_apply_filtering
                    onClicked: list_model_proxy.apply_all_filtering()
                    anchors.verticalCenter: parent.verticalCenter
                }
                Qaterial.OutlineButton {
                    icon.source: Qaterial.Icons.close
                    text: "Cancel All"
                    visible: !is_history && API.app.orders_mdl.length > 0
                    foregroundColor: Qaterial.Colors.pink
                    anchors.verticalCenter: parent.verticalCenter
                    outlinedColor: Style.colorTheme5
                    onClicked: API.app.trading_pg.orders.cancel_order(list_model_proxy.get_filtered_ids())
                }
            }
            RowLayout {
                visible: orders_settings.height > 75
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -15
                spacing: 10
                DefaultSweetComboBox {
                    id: combo_base
                    model: API.app.portfolio_pg.global_cfg_mdl.all_proxy
                    onCurrentTickerChanged: applyFilter()
                    Layout.fillWidth: true
                    height: 100
                    valueRole: "ticker"
                    textRole: 'ticker'
                }
                Qaterial.ColorIcon {
                    Layout.alignment: Qt.AlignVCenter
                    source: Qaterial.Icons.swapHorizontal
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

                DefaultSweetComboBox {
                    id: combo_rel
                    model: API.app.portfolio_pg.global_cfg_mdl.all_proxy //combo_base.model
                    onCurrentTickerChanged: applyFilter()
                    Layout.fillWidth: true
                    height: 100
                    valueRole: "ticker"
                    textRole: 'ticker'
                }
                Qaterial.TextFieldDatePicker {
                    id: min_date
                    title: qsTr("From")
                    from: default_min_date
                    to: default_max_date
                    date: default_min_date
                    font.pixelSize: 13
                    opacity: .8
                    color: DexTheme.foregroundColor
                    backgroundColor: DexTheme.portfolioPieGradient ? '#FFFFFF' : 'transparent'
                    onAccepted: applyDateFilter()
                    Layout.fillWidth: true
                }

                Qaterial.TextFieldDatePicker {
                    id: max_date
                    enabled: min_date.enabled
                    title: qsTr("To")
                    from: min_date.date
                    to: default_max_date
                    date: default_max_date
                    font.pixelSize: 13
                    opacity: .8
                    color: DexTheme.foregroundColor
                    backgroundColor: DexTheme.portfolioPieGradient ? '#FFFFFF' : 'transparent'
                    onAccepted: applyDateFilter()
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: parent.spacing

            OrderList {
                id: order_list
                items: list_model
                is_history: root.is_history
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

        }
    }
    ModalLoader {
        id: order_modal
        sourceComponent: OrderModal {}
    }

    FileDialog {
        id: export_csv_dialog

        title: qsTr("Please choose the CSV export name and location")
        fileMode: FileDialog.SaveFile

        defaultSuffix: "csv"
        nameFilters: ["CSV files (*.csv)", "All files (*)"]

        onAccepted: {
            const path = currentFile.toString()

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
