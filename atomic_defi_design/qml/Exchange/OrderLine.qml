import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

AnimatedRectangle {
    property var details
    readonly property bool is_placed_order: !details ? false :
                                                       details.order_id !== ''

    width: list.width
    height: 40

    color: Style.colorOnlyIf(mouse_area.containsMouse, Style.colorTheme8)

    // Swap icon
    DefaultImage {
        visible: !status_text.visible
        source: General.image_path + "exchange-exchange.svg"
        width: base_amount.font.pixelSize
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Matching icon
    RowLayout {
        id: status_text
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 5
        visible: !details ? false :
                 (details.is_swap || !details.is_maker)

        DefaultText {
            font.pixelSize: base_amount.font.pixelSize
            color: !details ? "white" : getStatusColor(details.order_status)
            text_value: API.app.settings_pg.empty_string + (!details ? "" :
                                                             visible ? getStatusTextWithPrefix(details.order_status, true) : '')
        }

        DefaultBusyIndicator {
            visible: !isSwapDone(details.order_status)
            Layout.preferredWidth: 20
            Layout.preferredHeight: Layout.preferredWidth
        }
    }



    DefaultMouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            order_modal.details = details
            order_modal.open()
        }
    }

    // Base Icon
    DefaultImage {
        id: base_icon
        source: General.coinIcon(!details ? "KMD" :
                                            details.base_coin)
        width: Style.textSize2

        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.225
        anchors.verticalCenter: parent.verticalCenter
    }

    // Base Amount
    DefaultText {
        id: base_amount
        text_value: API.app.settings_pg.empty_string + (!details ? "" :
                                                         General.formatCrypto("", details.base_amount, details.base_coin))
        font.pixelSize: Style.textSizeSmall4
        color: Style.getCoinColor(!details ? "white" : details.base_coin)

        anchors.left: base_icon.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        privacy: is_placed_order
    }

    // Rel Amount
    DefaultText {
        id: rel_amount
        text_value: API.app.settings_pg.empty_string + (!details ? "" :
                                                         General.formatCrypto("", details.rel_amount, details.rel_coin))
        font.pixelSize: base_amount.font.pixelSize
        color: Style.getCoinColor(!details ? "white" : details.rel_coin)

        anchors.right: rel_icon.left
        anchors.rightMargin: base_amount.anchors.leftMargin
        anchors.verticalCenter: base_amount.verticalCenter
        privacy: is_placed_order
    }

    // Rel Icon
    DefaultImage {
        id: rel_icon
        source: General.coinIcon(!details ? "KMD" :
                                            details.rel_coin)

        width: base_icon.width
        anchors.right: parent.right
        anchors.rightMargin: base_icon.anchors.leftMargin
        anchors.verticalCenter: parent.verticalCenter
    }

    // Date
    DefaultText {
        font.pixelSize: base_amount.font.pixelSize
        text_value: API.app.settings_pg.empty_string + (!details ? "" :
                                                        details.date)
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    // Order ID
    DefaultText {
        font.pixelSize: base_amount.font.pixelSize
        text_value: API.app.settings_pg.empty_string + (!details ? "" :
                                                        details.order_id)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20
        privacy: true
    }

    HorizontalLine {
        visible: index !== items.length -1
        width: parent.width
        color: Style.colorWhite9
        anchors.bottom: parent.bottom
    }
}




/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
