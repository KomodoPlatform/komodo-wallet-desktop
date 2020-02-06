import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_orders

    function updateOrders() {
        all_orders = API.get().get_my_orders()
        update_timer.running = true
        console.log(baseCoins())
    }

    function baseCoins() {
        return API.get().enabled_coins
    }

    function getOrders() {
        if(base === "" || all_orders[base] === undefined) {
            return { maker_order: [], taker_order: [] }
        }

        return all_orders[base].orders
    }

    property string base
    property var all_orders: ({})

    onBaseChanged: updateOrders()

    Timer {
        id: update_timer
        running: false
        repeat: true
        interval: 30000
        onTriggered: updateOrders()
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
            }
        }

        // Bottom part
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: parent.spacing

            OrderList {
                title: qsTr("Maker Orders")
                items: getOrders().maker_order
                type: qsTr("maker")

                function postCancelOrder() {
                    updateOrders()
                }
            }

            OrderList {
                title: qsTr("Taker Orders")
                items: getOrders().taker_order
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
