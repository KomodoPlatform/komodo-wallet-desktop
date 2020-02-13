import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_history


    function onOpened() {
        updateOrders()
    }

    function updateOrders() {
        all_orders = API.get().get_recent_swaps()
    }

    function getOrders() {
        return General.filterRecentSwaps(all_orders, true)
    }

    property var all_orders: ({})

    Timer {
        id: update_timer
        running: exchange.current_page === General.idx_exchange_history
        repeat: true
        interval: 5000
        onTriggered: updateOrders()
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.height
        spacing: 15

        SwapList {
            title: qsTr("Recent Swaps")
            items: getOrders()
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
