import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Content
Rectangle {
    property var item
    property bool in_modal: false

    color: "transparent"

    // Base Icon
    Image {
        id: base_icon
        source: General.coinIcon(item.my_info.my_coin)
        fillMode: Image.PreserveAspectFit
        width: in_modal ? Style.textSize5 : Style.textSize3
        anchors.horizontalCenter: base_amount.horizontalCenter
    }

    // Rel Icon
    Image {
        id: rel_icon
        source: General.coinIcon(item.my_info.other_coin)
        fillMode: Image.PreserveAspectFit
        width: base_icon.width
        anchors.horizontalCenter: rel_amount.horizontalCenter
    }

    // Base Amount
    DefaultText {
        id: base_amount
        text: "~ " + General.formatCrypto("", item.my_info.my_amount,
                                              item.my_info.my_coin)
        font.pointSize: in_modal ? Style.textSize2 : Style.textSize

        anchors.left: parent.left
        anchors.top: base_icon.bottom
        anchors.topMargin: 10
    }

    // Swap icon
    Image {
        source: General.image_path + "exchange-exchange.svg"
        width: base_amount.font.pointSize
        height: width
        anchors.verticalCenter: base_icon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Rel Amount
    DefaultText {
        id: rel_amount
        text: "~ " + General.formatCrypto("", item.my_info.other_amount,
                                              item.my_info.other_coin)
        font.pointSize: base_amount.font.pointSize
        anchors.right: parent.right
        anchors.top: base_amount.top
    }

    // UUID
    DefaultText {
        id: uuid
        visible: !in_modal
        text: (item.is_recent_swap ? qsTr("Swap ID") : qsTr("UUID")) + ": " + item.uuid
        color: Style.colorTheme2
        anchors.top: base_amount.bottom
        anchors.topMargin: base_amount.anchors.topMargin
    }

    // Status Text
    DefaultText {
        visible: !in_modal && (item.events !== undefined || item.am_i_maker === false)
        color: visible ? getStatusColor(item) : ''
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: base_icon.top
        text: visible ? qsTr(getStatusTextWithPrefix(item)) : ''
    }

    // Date
    DefaultText {
        id: date
        visible: !in_modal
        text: item.date
        color: Style.colorTheme2
        anchors.top: uuid.bottom
        anchors.topMargin: base_amount.anchors.topMargin
    }

    // Cancel button
    DangerButton {
        visible: !in_modal && item.cancellable !== undefined && item.cancellable
        anchors.right: parent.right
        anchors.bottom: date.bottom
        text: qsTr("Cancel")
        onClicked: onCancelOrder(item.uuid)
    }
}
