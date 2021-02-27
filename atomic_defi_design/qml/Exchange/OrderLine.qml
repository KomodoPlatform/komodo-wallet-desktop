import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

AnimatedRectangle {
    property var details
    property alias clickable: mouse_area.enabled
    readonly property bool is_placed_order: !details ? false :
                                                       details.order_id !== ''

    width: list.model.count>6? list.width-15 : list.width-8
    height: 40

    color: Style.colorOnlyIf(mouse_area.containsMouse, Style.colorTheme8)

    DefaultMouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: enabled
        onClicked: {
            order_modal.open()
            order_modal.item.details = details
        }
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        RowLayout {
            id: status_text
            Layout.fillHeight: true
            Layout.preferredWidth: 45

            spacing: 5
            visible: clickable? !details ? false :
                     (details.is_swap || !details.is_maker) : false

            DefaultText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: base_amount.font.pixelSize
                color: !details ? "white" : getStatusColor(details.order_status)
                text_value: !details ? "" :
                            visible ? getStatusStep(details.order_status) : ''
            }

            DefaultBusyIndicator {
                Layout.alignment: Qt.AlignVCenter
                visible: !isSwapDone(details.order_status)
                Layout.preferredWidth: 20
                Layout.preferredHeight: Layout.preferredWidth
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 45

            visible: !status_text.visible? clickable? true : false : false

            Qaterial.ColorIcon {
                anchors.centerIn: parent
                iconSize: 17
                color: Style.colorWhite4
                source: Qaterial.Icons.clipboardTextSearchOutline
            }
        }

        DefaultText {
            visible: clickable
            font.pixelSize: base_amount.font.pixelSize
            text_value: !details ? "" :
                        details.date?? ""
            Layout.fillHeight: true
            verticalAlignment: Label.AlignVCenter
            Layout.preferredWidth: 140
        }

        DefaultImage {
            id: base_icon
            source: General.coinIcon(!details ? "KMD" :
                                                details.base_coin?? "KMD")
            Layout.preferredWidth: Style.textSize1
            Layout.preferredHeight: Style.textSize1
            Layout.alignment: Qt.AlignVCenter
        }
        DefaultText {
            id: base_amount
            text_value: !details ? "" :
                        General.formatCrypto("", details.base_amount, details.base_coin, details.base_amount_current_currency, API.app.settings_pg.current_currency)
            font.pixelSize: Style.textSizeSmall2


            Layout.fillHeight: true
            Layout.preferredWidth: 180
            verticalAlignment: Label.AlignVCenter
            privacy: is_placed_order
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            SwapIcon {
                visible: !status_text.visible
                width: 30
                height: 50
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                top_arrow_ticker: !details ? "KMD" :
                                             details.base_coin?? ""
                bottom_arrow_ticker: !details ? "KMD" :
                                                details.rel_coin?? ""
            }
        }

        DefaultText {
            id: rel_amount
            text_value: !details ? "" :
                        General.formatCrypto("", details.rel_amount, details.rel_coin, details.rel_amount_current_currency, API.app.settings_pg.current_currency)
            font.pixelSize: base_amount.font.pixelSize

            Layout.fillHeight: true
            Layout.preferredWidth: 180
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignRight
            privacy: is_placed_order
        }
        DefaultImage {
            id: rel_icon
            source: General.coinIcon(!details ? "KMD" :
                                                details.rel_coin?? "BTC")

            width: base_icon.width
            Layout.preferredWidth: Style.textSize1
            Layout.preferredHeight: Style.textSize1
            Layout.alignment: Qt.AlignVCenter
        }
        DefaultText {
            font.pixelSize: base_amount.font.pixelSize
            visible: !details || details.recoverable === undefined ? false :
                     details.recoverable && details.order_status !== "refunding"
            Layout.fillHeight: true
            Layout.preferredWidth: 40
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
            text_value: Style.warningCharacter
            color: Style.colorYellow

            DefaultTooltip {
                visible: (parent.visible && mouse_area.containsMouse) ?? false

                contentItem: ColumnLayout {
                    DefaultText {
                        text_value: qsTr("Funds are recoverable")
                        font.pixelSize: Style.textSizeSmall4
                    }
                }
            }
        }
        Qaterial.FlatButton {
            id: cancel_button_text
            visible: (!is_history? details.cancellable?? false : false)===true? (mouse_area.containsMouse || hovered)? true : false : false

            icon.source: Qaterial.Icons.close
            Layout.fillHeight: true
            Layout.preferredWidth: 30
            foregroundColor: Qaterial.Colors.pink300
            Layout.alignment: Qt.AlignVCenter
            outlinedColor: Style.colorTheme5
            Behavior on scale {
                NumberAnimation { duration: 200 }
            }

            scale: visible? 1 : 0
            onClicked: { if(details) cancelOrder(details.order_id) }
            hoverEnabled: true

        }
        Rectangle {
            visible: (!is_history? details.cancellable?? false : false) === true? (mouse_area.containsMouse || cancel_button_text.hovered )? false : true : false
            width: 5
            height: 5
            color: Style.colorRed
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 40
            visible: !clickable
        }
    }





    // Order ID
    HorizontalLine {
        width: parent.width
        color: Style.colorWhite9
        anchors.bottom: parent.bottom
    }
}
