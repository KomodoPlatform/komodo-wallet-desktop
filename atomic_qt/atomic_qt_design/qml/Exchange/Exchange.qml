import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"
import "./Trade"

Item {
    id: exchange
    property int current_page: General.idx_exchange_trade

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Layout.fillWidth: true

        spacing: 20
        // Top tabs
        RowLayout {
            id: tabs
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            spacing: 40

            ExchangeTab {
                dashboard_index: General.idx_exchange_trade
                text: "Trade"
            }

            ExchangeTab {
                dashboard_index: General.idx_exchange_orders
                text: "Orders"
            }

            ExchangeTab {
                dashboard_index: General.idx_exchange_history
                text: "History"
            }

            ExchangeTab {
                dashboard_index: General.idx_exchange_orderbook
                text: "Orderbook"
            }
        }

        HorizontalLine {
            width: tabs.width * 1.1
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        // Bottom content
        StackLayout {
            transformOrigin: Item.Center

            currentIndex: current_page

            Trade {

            }

            DefaultText {
                text: qsTr("Content-Orders")
            }

            DefaultText {
                text: qsTr("Content-History")
            }

            DefaultText {
                text: qsTr("Content-Orderbook")
            }
        }
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:1200}
}
##^##*/
