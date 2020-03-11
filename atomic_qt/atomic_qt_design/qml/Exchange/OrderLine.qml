import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Rectangle {
    property var item
    width: parent.width
    height: 175

    property bool hovered: false

    color: hovered ? Style.colorTheme8 : "transparent"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: hovered = containsMouse
        onClicked: order_modal.open()
    }

    OrderModal {
        id: order_modal
        details: item
    }

    OrderContent {
        width: parent.width * 0.9
        height: 200

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        item: parent.item
    }

    HorizontalLine {
        visible: index !== items.length -1
        width: parent.width
        color: Style.colorWhite9
        anchors.bottom: parent.bottom
    }



    // Status Info
    readonly property int status_swap_not_swap: -1
    readonly property int status_swap_matching: 0
    readonly property int status_swap_matched: 1
    readonly property int status_swap_ongoing: 2
    readonly property int status_swap_successful: 3
    readonly property int status_swap_failed: 4

    function getSwapError(swap) {
        if(swap.is_recent_swap) {
            for(let i = swap.events.length - 1; i > 0; --i) {
                const e = swap.events[i]
               if(swap.error_events.indexOf(e.state) !== -1) {
                   return e
               }
            }
        }

        return { state: '', data: { error: '' } }
    }

    function getStatus(swap) {
        if(swap.am_i_maker !== undefined && !swap.am_i_maker) return status_swap_matching
        if(!swap.is_recent_swap) return status_swap_not_swap

        const last_state = swap.events[swap.events.length-1].state

        if(last_state === "Started") return status_swap_matched
        if(last_state === "Finished") return getSwapError(swap).state === '' ? status_swap_successful : status_swap_failed

        return status_swap_ongoing
    }

    function getStatusColor(swap) {
        const status = getStatus(swap)
        return status === status_swap_matching ? Style.colorYellow :
               status === status_swap_matched ? Style.colorOrange :
               status === status_swap_ongoing ? Style.colorOrange :
               status === status_swap_successful ? Style.colorGreen : Style.colorRed
    }

    function getStatusText(swap) {
        const status = getStatus(swap)
        return qsTr(status === status_swap_matching ? "Order Matching":
                    status === status_swap_matched ? "Order Matched":
                    status === status_swap_ongoing ? "Swap Ongoing":
                    status === status_swap_successful ? "Swap Successful" : "Swap Failed")
    }

    function getStatusStep(swap) {
        const status = getStatus(swap)
        return status === status_swap_matching ? "0/3":
               status === status_swap_matched ? "1/3":
               status === status_swap_ongoing ? "2/3":
               status === status_swap_successful ? "✓" : "✘"
    }

    function getStatusTextWithPrefix(swap) {
        return getStatusStep(swap) + " " + getStatusText(swap)
    }

    function getSwapPaymentID(swap, is_taker) {
        if(swap.events !== undefined) {
            const search_name = is_taker ? "TakerPaymentSent" : "MakerPaymentSpent"
            for(const e of swap.events) {
               if(e.state === search_name) {
                   return e.data.tx_hash
               }
            }
        }

        return ''
    }
}




/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
