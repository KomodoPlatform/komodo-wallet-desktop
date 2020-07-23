import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"
import ".."

Item {
    id: exchange_orders

    property string base
    property var orders_model: API.get().orders_mdl

    // Local
    function onCancelOrder(order_id) {
        API.get().cancel_order(order_id)
    }


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
        console.log("is_history false")
        API.get().orders_mdl.orders_proxy_mdl.is_history = false
        API.get().refresh_orders_and_swaps()
    }

    function baseCoins() {
        return API.get().enabled_coins
    }

    function changeTicker(ticker) {
        combo_base.currentIndex = baseCoins().map(c => c.ticker).indexOf(ticker)
    }

    function cancellableOrderExists() {
        // TODO: Implement later, as property
        return false
//        for(const i in orders_model) {
//            const o = orders_model[i]
//            if(o.cancellable !== undefined && o.cancellable)
//                return true
//        }

//        return false
    }

    // Orders page quick refresher, used right after a fresh successful trade
    function onOrderPlaced() {
        refresh_faster.restart()
        refresh_timer.restart()
    }

    Timer {
        id: refresh_timer
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: {
            if(inCurrentPage()) {
                API.get().refresh_orders_and_swaps()
            }
        }
    }

    Timer {
        id: refresh_faster
        interval: 2000
        onTriggered: {
            console.log("Refreshing faster for " + interval + " ms!")
            refresh_timer.stop()
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.height
        spacing: 15

        // Select coins row
        FloatingBackground {
            Layout.alignment: Qt.AlignHCenter
            width: layout.width
            height: layout.height

            RowLayout {   
                id: layout
                             
                Switch {
                    id: show_all_coins
                    Layout.leftMargin: 15
                    text: API.get().empty_string + (qsTr("Show All Coins"))

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
                    Layout.preferredWidth: 250
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    Layout.rightMargin: 15

                    model: General.fullNamesOfCoins(baseCoins())
                    onCurrentTextChanged: {
                        base = baseCoins()[currentIndex].ticker
                    }
                }

                DangerButton {
                    text: API.get().empty_string + (show_all_coins.checked ? qsTr("Cancel All Orders") : qsTr("Cancel All %1 Orders", "TICKER").arg(base))
                    enabled: cancellableOrderExists()
                    onClicked: {
                        if(show_all_coins.checked) API.get().cancel_all_orders()
                        else API.get().cancel_all_orders_by_ticker(base)
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
                title: API.get().empty_string + (show_all_coins.checked ? qsTr("All Orders") : qsTr("All %1 Orders", "TICKER").arg(base))
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
