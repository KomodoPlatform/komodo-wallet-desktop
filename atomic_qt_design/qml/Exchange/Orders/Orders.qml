import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"
import ".."

Item {
    id: exchange_orders

    property string base
    property var all_orders: ({})
    property var all_recent_swaps: ({})
    property var all_orders_merged: ([])

    // Local
    function onCancelOrder(uuid) {
        API.get().cancel_order(uuid)
        updateOrders()
    }


    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === General.idx_exchange_orders
    }

    onBaseChanged: updateOrders()

    function reset() {
        all_orders = {}
        all_recent_swaps = {}
        all_orders_merged = []
        update_timer.running = false
    }

    function onOpened() {
        // Force a refresh, myOrdersUpdated will call updateOrders once it's done
        API.get().refresh_infos()
    }

    Component.onCompleted: {
        API.get().myOrdersUpdated.connect(updateOrders)
    }

    function getRecentSwaps(ticker) {
        return General.filterRecentSwaps(all_recent_swaps, "exclude", ticker)
    }

    function updateOrders() {
        all_orders = API.get().get_my_orders()
        all_recent_swaps = API.get().get_recent_swaps()
        all_orders_merged = getAllOrders()
        update_timer.running = true
    }

    function baseCoins() {
        return API.get().enabled_coins
    }

    function getOrders() {
        let mixed_orders = { maker_orders: [], taker_orders: [] }

        if(base !== "" && all_orders[base] !== undefined) {
            // Add recent swaps
            getRecentSwaps(base).map(s => {
                mixed_orders[s.type === "Taker" ? "taker_orders" : "maker_orders"].push(s)
            })

            // Add normal orders
            mixed_orders.taker_orders = mixed_orders.taker_orders.concat(all_orders[base].taker_orders)
            mixed_orders.maker_orders = mixed_orders.maker_orders.concat(all_orders[base].maker_orders)
        }

        return mixed_orders
    }

    function getAllOrders() {
        let orders = getOrders()

        return orders.taker_orders.concat(orders.maker_orders)
    }

    function changeTicker(ticker) {
        combo_base.currentIndex = baseCoins().map(c => c.ticker).indexOf(ticker)
    }

    function cancellableOrderExists() {
        for(const i in all_orders_merged) {
            const o = all_orders_merged[i]
            if(o.cancellable !== undefined && o.cancellable)
                return true
        }

        return false
    }

    Timer {
        id: update_timer
        running: false
        repeat: true
        interval: 5000
        onTriggered: {
            if(inCurrentPage()) updateOrders()
        }
    }

    // Orders page quick refresher, used right after a fresh successful trade
    function onOrderPlaced() {
        refresh_faster.restart()
        refresh_timer.restart()
    }

    Timer {
        id: refresh_timer
        repeat: true
        interval: refresh_faster.running ? 500 : 5000
        triggeredOnStart: true
        onTriggered: {
            if(inCurrentPage()) {
                API.get().refresh_orders_and_swaps()
            }
        }
    }

    Timer {
        id: refresh_faster
        interval: 10000
        onTriggered: {
            console.log("Refreshing faster for " + interval + " ms!")
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.height
        spacing: 15

        // Select coins row
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height

            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius

            RowLayout {
                // Base
                Image {
                    Layout.leftMargin: 15
                    source: General.coinIcon(base)
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                DefaultComboBox {
                    id: combo_base
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
                    text: API.get().empty_string + (qsTr("Cancel All Orders"))
                    enabled: cancellableOrderExists()
                    onClicked: API.get().cancel_all_orders_by_ticker(base)
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
                title: API.get().empty_string + (qsTr("All %1 Orders", "TICKER").arg(base))
                items: all_orders_merged
            }
        }

        OrderModal {
            id: order_modal
            details: General.formatOrder(all_orders_merged.map(o => o.uuid).indexOf(order_modal.current_item_uuid) !== -1 ?
                                        all_orders_merged[all_orders_merged.map(o => o.uuid).indexOf(order_modal.current_item_uuid)] : default_details)

            onDetailsChanged: {
                if(details.is_default) close()
            }
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
