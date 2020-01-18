import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property int current_page: General.idx_exchange_trade

    spacing: 20
    // Top tabs
    RowLayout {
        id: tabs
        Layout.alignment: Qt.AlignHCenter

        spacing: 40

        DefaultText {
            text: "Trade"
            font.pointSize: Style.textSize2
        }

        DefaultText {
            text: "Orders"
            font.pointSize: Style.textSize2
        }

        DefaultText {
            text: "History"
            font.pointSize: Style.textSize2
        }

        DefaultText {
            text: "Orderbook"
            font.pointSize: Style.textSize2
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
