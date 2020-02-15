import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Content
Rectangle {
    property var item
    property bool hide_status: false

    color: "transparent"
    height: 200

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
        text: (item.is_recent_swap ? qsTr("Swap ID") : qsTr("UUID")) + ": " + item.uuid
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
        visible: !hide_status && (item.events !== undefined || item.am_i_maker === false)
        color: visible ? getStatusColor(item) : ''
        anchors.right: parent.right
        anchors.top: date.top
        text: visible ? qsTr(getStatusTextWithPrefix(item)) : ''
    }
}
