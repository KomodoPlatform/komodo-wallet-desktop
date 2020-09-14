import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"
import ".."

Item {
    id: exchange_orders

    property string base
    property var orders_model: API.get().orders_mdl

    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === General.idx_exchange_orders
    }

    function applyFilter() {
        orders_model.orders_proxy_mdl.setFilterFixedString(show_all_coins.checked ? "" : base)
    }

    onBaseChanged: applyFilter()

    function reset() {  }

    function onOpened() {
        applyFilter()
        API.get().orders_mdl.orders_proxy_mdl.is_history = false
        API.get().refresh_orders_and_swaps()
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
                             
                Switch {
                    id: show_all_coins
                    Layout.leftMargin: 15
                    text: API.get().settings_pg.empty_string + (qsTr("Show All Coins"))

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

                    model: General.fullNamesOfCoins(API.get().enabled_coins)
                    onCurrentTextChanged: {
                        base = model[currentIndex].value
                    }
                }

                DangerButton {
                    text: API.get().settings_pg.empty_string + (show_all_coins.checked ? qsTr("Cancel All Orders") : qsTr("Cancel All %1 Orders", "TICKER").arg(base))
                    enabled: orders_model.length > 0
                    onClicked: {
                        if(show_all_coins.checked) API.get().trading_pg.cancel_all_orders()
                        else API.get().trading_pg.cancel_all_orders_by_ticker(base)
                    }
                    Layout.rightMargin: 15
                }
            }
        }

        // Bottom part
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: parent.spacing

            OrderList {
                title: API.get().settings_pg.empty_string + (show_all_coins.checked ? qsTr("All Orders") : qsTr("All %1 Orders", "TICKER").arg(base))
                items: orders_model
            }
        }

        OrderModal {
            id: order_modal
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
