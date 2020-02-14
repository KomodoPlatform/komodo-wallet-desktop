import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_orders

    function getRecentSwaps(ticker) {
        return General.filterRecentSwaps(all_recent_swaps, "exclude", ticker)
    }

    function updateOrders() {
        all_orders = API.get().get_my_orders()
        all_recent_swaps = API.get().get_recent_swaps()
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

    function changeTicker(ticker) {
        combo_base.currentIndex = baseCoins().map(c => c.ticker).indexOf(ticker)
    }

    property string base
    property var all_orders: ({})
    property var all_recent_swaps: ({})

    onBaseChanged: updateOrders()

    Timer {
        id: update_timer
        running: false
        repeat: true
        interval: 5000
        onTriggered: updateOrders()
    }

    Component.onCompleted: {
        API.get().myOrdersUpdated.connect(updateOrders)
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

                ComboBox {
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

                Button {
                    text: qsTr("Cancel All Orders")
                    enabled: getOrders().maker_orders.length > 0 || getOrders().taker_orders.length > 0
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
                title: qsTr("Maker Orders")
                items: getOrders().maker_orders
                type: qsTr("maker")

                function postCancelOrder() {
                    updateOrders()
                }
            }

            OrderList {
                title: qsTr("Taker Orders")
                items: getOrders().taker_orders
                type: qsTr("taker")

                function postCancelOrder() {
                    updateOrders()
                }
            }
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
