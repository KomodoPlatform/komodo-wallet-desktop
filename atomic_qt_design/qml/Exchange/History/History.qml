import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"
import ".."

Item {
    id: exchange_history

    property var all_recent_swaps: ({})

    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === General.idx_exchange_history
    }

    function reset() {
        update_timer.restart()
        update_timer.running = inCurrentPage()
        all_recent_swaps = {}
    }

    function onOpened() {
        updateRecentSwaps()
    }

    function updateRecentSwaps() {
        all_recent_swaps = API.get().get_recent_swaps()
    }

    function getRecentSwaps() {
        return General.filterRecentSwaps(all_recent_swaps, "include")
    }

    property string recover_funds_result: '{}'

    function onRecoverFunds(uuid) {
        const result = API.get().recover_fund(uuid)
        console.log(result)
        recover_funds_result = result
        recover_funds_modal.open()
        updateRecentSwaps()
    }

    Timer {
        id: update_timer
        running: inCurrentPage()
        repeat: true
        interval: 5000
        onTriggered: {
            if(inCurrentPage()) updateRecentSwaps()
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.height
        spacing: 15

        SwapList {
            title: API.get().empty_string + (qsTr("Recent Swaps"))
            items: getRecentSwaps()
        }
    }

    OrderModal {
        id: order_modal
        details: General.formatOrder(getRecentSwaps().map(o => o.uuid).indexOf(order_modal.current_item_uuid) !== -1 ?
                                    getRecentSwaps()[getRecentSwaps().map(o => o.uuid).indexOf(order_modal.current_item_uuid)] : default_details)

        onDetailsChanged: {
            if(details.is_default) close()
        }
    }

    LogModal {
        id: recover_funds_modal

        title: API.get().empty_string + (qsTr("Recover Funds Result"))
        field.text: JSON.stringify(JSON.parse(recover_funds_result), null, 4)

        onClosed: recover_funds_result = "{}"
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
