import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Content
Item {
    property var item
    property bool in_modal: false

    readonly property bool is_placed_order: item.order_id !== ''

    // Base Icon
    DefaultImage {
        id: base_icon
        source: General.coinIcon(item.base_coin)
        fillMode: Image.PreserveAspectFit
        width: in_modal ? Style.textSize5 : Style.textSize3
        anchors.horizontalCenter: base_amount.horizontalCenter
    }

    // Rel Icon
    DefaultImage {
        id: rel_icon
        source: General.coinIcon(item.rel_coin)
        fillMode: Image.PreserveAspectFit
        width: base_icon.width
        anchors.horizontalCenter: rel_amount.horizontalCenter
    }

    // Base Amount
    DefaultText {
        id: base_amount
        text_value: API.get().empty_string + ("~ " + General.formatCrypto("", item.base_amount, item.base_coin))
        font.pixelSize: in_modal ? Style.textSize2 : Style.textSize

        anchors.left: parent.left
        anchors.top: base_icon.bottom
        anchors.topMargin: 10
        privacy: is_placed_order
    }

    // Swap icon
    DefaultImage {
        source: General.image_path + "exchange-exchange.svg"
        width: base_amount.font.pixelSize
        height: width
        anchors.verticalCenter: base_icon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Rel Amount
    DefaultText {
        id: rel_amount
        text_value: API.get().empty_string + ("~ " + General.formatCrypto("", item.rel_amount, item.rel_coin))
        font.pixelSize: base_amount.font.pixelSize
        anchors.right: parent.right
        anchors.top: base_amount.top
        privacy: is_placed_order
    }

    // Order ID
    DefaultText {
        id: order_id
        visible: !in_modal && is_placed_order
        text_value: API.get().empty_string + (qsTr("ID") + ": " + item.order_id)
        color: Style.colorTheme2
        anchors.top: base_amount.bottom
        anchors.topMargin: base_amount.anchors.topMargin
        privacy: is_placed_order
    }

    // Status Text
    // TODO: Events is missing
//    DefaultText {
//        visible: !in_modal && (item.events !== undefined || item.is_maker === false)
//        color: visible ? getStatusColor(item.order_status) : ''
//        anchors.horizontalCenter: parent.horizontalCenter
//        anchors.top: base_icon.top
//        text_value: API.get().empty_string + (visible ? getStatusTextWithPrefix(item.order_status) : '')
//    }

    // Date
    DefaultText {
        id: date
        visible: !in_modal && item.date !== ''
        text_value: API.get().empty_string + (item.date)
        color: Style.colorTheme2
        anchors.top: order_id.bottom
        anchors.topMargin: base_amount.anchors.topMargin
    }

    // Maker/Taker
    DefaultText {
        visible: !in_modal && is_placed_order
        text_value: API.get().empty_string + (item.is_maker ? qsTr("Maker Order"): qsTr("Taker Order"))
        color: Style.colorThemeDarkLight
        anchors.verticalCenter: date.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Cancel button
    DangerButton {
        visible: !in_modal && item.cancellable !== undefined && item.cancellable
        anchors.right: parent.right
        anchors.bottom: date.bottom
        text: API.get().empty_string + (qsTr("Cancel"))
        onClicked: onCancelOrder(item.order_id)
    }

    // Recover Funds button
    // TODO: Add is_recoverable
//    PrimaryButton {
//        visible: !in_modal && item.is_recoverable !== undefined && item.is_recoverable
//        anchors.right: parent.right
//        anchors.bottom: date.bottom
//        text: API.get().empty_string + (qsTr("Recover Funds"))
//        onClicked: onRecoverFunds(item.order_id)
//    }
}
