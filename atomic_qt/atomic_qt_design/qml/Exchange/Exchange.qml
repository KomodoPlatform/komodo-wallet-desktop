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

    function changeBase(ticker) {
        exchange_trade.changeBase(ticker)
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        anchors.fill: parent

        spacing: 20

        // Top tabs
        RowLayout {
            id: tabs
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.topMargin: 30
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
        }

        HorizontalLine {
            width: tabs.width * 1.25
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        // Bottom content
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: 15
            Layout.leftMargin: Layout.bottomMargin
            Layout.rightMargin: Layout.bottomMargin

            currentIndex: current_page

            Trade {
                id: exchange_trade
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
