import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0

import App 1.0

import Qaterial 1.0 as Qaterial

import "../../../Components"

// Content
Item {
    property
    var details
    property bool in_modal: false

    readonly property bool is_placed_order: !details ? false :
        details.order_id !== ''

    

    // Base Icon
    /*DefaultImage {
        id: base_icon
        source: General.coinIcon(!details ? atomic_app_primary_coin :
            details.base_coin)
        width: in_modal ? Style.textSize5 : Style.textSize3

        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.2
    }*/

    /*// Rel Icon
    DefaultImage {
        id: rel_icon
        source: General.coinIcon(!details ? atomic_app_primary_coin :
            details.rel_coin)
        width: base_icon.width
        anchors.right: parent.right
        anchors.rightMargin: base_icon.anchors.leftMargin
    }

    // Base Amount
    DefaultText {
        id: base_amount
        text_value: !details ? "" : "~ " + General.formatCrypto("", details.base_amount, details.base_coin)
        font.pixelSize: in_modal ? Style.textSize2 : Style.textSize

        anchors.horizontalCenter: base_icon.horizontalCenter
        anchors.top: base_icon.bottom
        anchors.topMargin: 10
        privacy: is_placed_order
    }

    // Swap icon
    SwapIcon {
        anchors.verticalCenter: base_icon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        top_arrow_ticker: !details ? atomic_app_primary_coin :
            details.base_coin
        bottom_arrow_ticker: !details ? atomic_app_primary_coin :
            details.rel_coin
    }

    // Rel Amount
    DefaultText {
        id: rel_amount
        text_value: !details ? "" : "~ " + General.formatCrypto("", details.rel_amount, details.rel_coin)
        font.pixelSize: base_amount.font.pixelSize

        anchors.horizontalCenter: rel_icon.horizontalCenter
        anchors.top: base_amount.top
        privacy: is_placed_order
    }

    // Order ID
    DefaultText {
        id: order_id
        visible: !in_modal && is_placed_order
        text_value: !details ? "" : qsTr("ID") + ": " + details.order_id
        color: Style.colorTheme2
        anchors.top: base_amount.bottom
        anchors.topMargin: base_amount.anchors.topMargin
        privacy: is_placed_order
    }

    // Status Text
    DefaultText {
        visible: !details ? false : !in_modal && (details.is_swap || !details.is_maker)
        color: !details ? "white" : visible ? getStatusColor(details.order_status) : ''
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: base_icon.top
        text_value: !details ? "" : visible ? getStatusTextWithPrefix(details.order_status) : ''
    }

    // Date
    DefaultText {
        id: date
        visible: !details ? false : !in_modal && details.date !== ''
        text_value: !details ? "" : details.date
        color: Style.colorTheme2
        anchors.top: order_id.bottom
        anchors.topMargin: base_amount.anchors.topMargin
    }

    // Maker/Taker
    DefaultText {
        visible: !in_modal && is_placed_order
        text_value: !details ? "" : details.is_maker ? qsTr("Maker Order") : qsTr("Taker Order")
        color: Style.colorThemeDarkLight
        anchors.verticalCenter: date.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Cancel button
    DangerButton {
        visible: !details ? false :
            !in_modal && details.cancellable
        anchors.right: parent.right
        anchors.bottom: date.bottom
        text: qsTr("Cancel")
        onClicked: cancelOrder(details.order_id)
    }*/
    RowLayout {
        width: 500
        height: 66
        anchors.centerIn: parent
        spacing: 23
        DexRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: DexTheme.contentColorTop
            RowLayout {
                width: parent.width - 40
                height: 50
                anchors.centerIn: parent
                spacing: 23
                DefaultImage {
                    id: base_icon
                    source: General.coinIcon(!details ? atomic_app_primary_coin :
                        details.base_coin)
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 35
                    Layout.alignment: Qt.AlignVCenter
                }
                DexLabel {
                    id: base_amount
                    text_value: !details ? "" : "<b><font color='"+DexTheme.getCoinColor(base_ticker)+"'>" +base_ticker+ "</font></b>"+"    %1".arg(General.coinName(base_ticker))+"<br>" + General.formatCrypto("", details.base_amount, details.base_coin).split(" ")[1]
                    font: DexTypo.body2

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    privacy: is_placed_order
                    opacity: .9
                }
            }
        }

        Qaterial.Icon {
            color: DexTheme.foregroundColor
            icon: Qaterial.Icons.swapHorizontal
            Layout.alignment: Qt.AlignVCenter
        }

        DexRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: DexTheme.contentColorTop
            RowLayout {
                width: parent.width - 40
                height: 50
                anchors.centerIn: parent
                spacing: 23
                DefaultImage {
                    id: rel_icon
                    source: General.coinIcon(!details ? atomic_app_primary_coin :
                        details.rel_coin)
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 35
                    Layout.alignment: Qt.AlignVCenter
                }
                DexLabel {
                    id: rel_amount
                    text_value: !details ? "" : "<b><font color='"+DexTheme.getCoinColor(rel_ticker)+"'>" +rel_ticker+ "</font></b>     %1 <br>".arg(General.coinName(rel_ticker)) + General.formatCrypto("", details.rel_amount, details.rel_coin).split(" ")[1]
                    font: DexTypo.body2

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    privacy: is_placed_order
                    opacity: .9
                }
            }
        }
    }
}