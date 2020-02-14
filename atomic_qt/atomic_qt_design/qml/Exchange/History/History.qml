import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_history

    function onOpened() {
        updateRecentSwaps()
    }

    function updateRecentSwaps() {
        all_recent_swaps = API.get().get_recent_swaps()
    }

    function getRecentSwaps() {
        return General.filterRecentSwaps(all_recent_swaps, "include")
    }

    property var all_recent_swaps: ({})

    Timer {
        id: update_timer
        running: exchange.current_page === General.idx_exchange_history
        repeat: true
        interval: 5000
        onTriggered: updateRecentSwaps()
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.height
        spacing: 15

        SwapList {
            title: qsTr("Recent Swaps")
            items: getRecentSwaps()
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
