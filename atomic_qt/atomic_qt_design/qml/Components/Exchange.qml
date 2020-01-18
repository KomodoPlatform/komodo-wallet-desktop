import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    id: exchange

    property int current_page: General.idx_exchange_trade

    spacing: 20
    // Top tabs
    RowLayout {
        id: tabs
        Layout.alignment: Qt.AlignHCenter

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

    Rectangle {
        width: tabs.width * 1.1
        height: 1
        color: Style.colorWhite5
    }

    // Bottom content
    StackLayout {
        transformOrigin: Item.Center

        currentIndex: current_page

        DefaultText {
            text: qsTr("Content-Trade")
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









/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:150}
}
##^##*/
