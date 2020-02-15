import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Rectangle {
    property var item: model.modelData
    property bool hovered: false

    color: hovered ? Style.colorTheme8 : "transparent"
    width: list.width
    height: 175

    // Content
    Rectangle {
        color: "transparent"
        width: parent.width * 0.8
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20

        // Base Icon
        Image {
            id: base_icon
            source: General.coinIcon(item.my_info.my_coin)
            fillMode: Image.PreserveAspectFit
            width: Style.textSize3
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.25
        }

        // Rel Icon
        Image {
            id: rel_icon
            source: General.coinIcon(item.my_info.other_coin)
            fillMode: Image.PreserveAspectFit
            width: Style.textSize3
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.25
        }

        // Base Amount
        DefaultText {
            id: base_amount
            text: "~ " + General.formatCrypto("", item.my_info.my_amount,
                                                  item.my_info.my_coin)
            anchors.left: parent.left
            anchors.top: base_icon.bottom
            anchors.topMargin: 10
        }

        // Swap icon
        Image {
            source: General.image_path + "exchange-exchange.svg"
            anchors.top: base_amount.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Rel Amount
        DefaultText {
            text: "~ " + General.formatCrypto("", item.my_info.other_amount,
                                                  item.my_info.other_coin)
            anchors.right: parent.right
            anchors.top: base_amount.top
        }

        // UUID
        DefaultText {
            id: uuid
            text: "UUID: " + item.uuid
            color: Style.colorTheme2
            anchors.top: base_amount.bottom
            anchors.topMargin: base_amount.anchors.topMargin
        }

        // Cancel button
        Button {
            visible: item.cancellable !== undefined && item.cancellable
            anchors.right: parent.right
            anchors.verticalCenter: rel_icon.verticalCenter
            text: qsTr("Cancel")
            onClicked: onCancelOrder(model.modelData.uuid)
        }

        // Date
        DefaultText {
            id: date
            text: item.date
            color: Style.colorTheme2
            anchors.top: uuid.bottom
            anchors.topMargin: base_amount.anchors.topMargin
        }

        // Status Text
        DefaultText {
            visible: item.events !== undefined || item.am_i_maker === false
            color: visible ? getStatusColor(item) : ''
            anchors.right: parent.right
            anchors.top: date.top
            text: visible ? qsTr(getStatusTextWithPrefix(item)) : ''
        }
    }

    HorizontalLine {
        visible: index !== items.length -1
        width: parent.width
        color: Style.colorWhite9
        anchors.top: col_layout.bottom
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: hovered = containsMouse
        onClicked: order_modal.open()
    }

    OrderModal {
        id: order_modal
        details: model.modelData
    }


    // Status Info
    readonly property int status_swap_matching: 0
    readonly property int status_swap_matched: 1
    readonly property int status_swap_ongoing: 2
    readonly property int status_swap_successful: 3
    readonly property int status_swap_failed: 4

    function getStatus(swap) {
        if(swap.am_i_maker !== undefined && !swap.am_i_maker) return status_swap_matching

        const last_state = swap.events[swap.events.length-1].state

        if(last_state === "Started") return status_swap_matched
        if(last_state === "Finished") {
            for(const e of swap.events) {
               if(swap.error_events.indexOf(e.status) !== -1)
                   return status_swap_failed
            }

            return status_swap_successful
        }

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
        return status === status_swap_matching ? "Order Matching":
               status === status_swap_matched ? "Order Matched":
               status === status_swap_ongoing ? "Swap Ongoing":
               status === status_swap_successful ? "Swap Successful" : "Swap Failed"
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
}




/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
