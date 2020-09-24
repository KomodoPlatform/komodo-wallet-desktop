import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import ".."

Item {
    id: root

    readonly property date year_ago: new Date(new Date().setFullYear(new Date().getFullYear() - 1))
    readonly property date now: new Date()


    property string base
    property var list_model: API.app.orders_mdl
    property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
    property int page_index

    property alias title: order_list.title
    property alias empty_text: order_list.empty_text
    property alias items: order_list.items

    property bool is_history: false

    property string recover_funds_result: '{}'

    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === page_index
    }

    function applyFilter() {
        list_model_proxy.setFilterFixedString(show_all_coins.checked ? "" : base)
    }

    onBaseChanged: applyFilter()

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
                    text: API.app.settings_pg.empty_string + (qsTr("Show All Coins"))

                    checked: true
                    onCheckedChanged: applyFilter()
                }

                // Base
                DefaultImage {
                    Layout.leftMargin: 15
                    source: General.coinIcon(base)
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                DefaultComboBox {
                    id: combo_base
                    enabled: !show_all_coins.checked
                    Layout.preferredWidth: 325
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    Layout.rightMargin: 15

                    textRole: "text"

                    model: General.fullNamesOfCoins(API.app.enabled_coins)
                    onCurrentTextChanged: {
                        base = model[currentIndex].value
                    }
                }

                DangerButton {
                    visible: !root.is_history
                    text: API.app.settings_pg.empty_string + (show_all_coins.checked ? qsTr("Cancel All Orders") : qsTr("Cancel All %1 Orders", "TICKER").arg(base))
                    enabled: list_model.length > 0
                    onClicked: {
                        if(show_all_coins.checked) API.app.trading_pg.cancel_all_orders()
                        else API.app.trading_pg.cancel_all_orders_by_ticker(base)
                    }
                    Layout.rightMargin: 15
                }

                Qaterial.TextFieldDatePicker {
                    id: min_date
                    from: year_ago
                    to: now
                    date: year_ago
                }

                Qaterial.TextFieldDatePicker {
                    id: max_date
                    from: year_ago
                    to: now
                    date: now
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

