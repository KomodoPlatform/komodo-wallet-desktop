//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! 3rdParty Imports
import Qaterial 1.0 as Qaterial

//! Project Imports
import "../../../Components"
import "../../../Constants"   //> Style
import "../Orders" as Orders
import "Main.js" as Main

DexListView {
    id: order_list_view
    anchors.fill: parent
    model: API.app.orders_mdl.orders_proxy_mdl
    clip: true
    currentIndex: -1
    delegate: ClipRRect {
        property var details: model
        readonly property bool is_placed_order: !details ? false :
                               details.order_id !== ''

        property bool expanded: order_list_view.currentIndex === index
        width: order_list_view.width
        height: expanded? colum_order.height+10 : 35
        radius: 1
        Rectangle {
            anchors.fill: parent
            color: order_mouse_area.containsMouse? theme.surfaceColor : 'transparent'
            border.color: theme.surfaceColor
            border.width: expanded? 1 : 0
        }
        DexMouseArea {
            id: order_mouse_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if(order_list_view.currentIndex === index) {
                    order_list_view.currentIndex = -1
                }else {
                    order_list_view.currentIndex = index
                }
            }
        }
        Column {
            id: colum_order
            width: parent.width
            spacing: 5
            RowLayout {
                width: parent.width
                height: 30
                spacing: 5
                Item {
                    Layout.preferredWidth: 30 
                    height: 30
                    BusyIndicator {
                        width: 25
                        height: width
                        anchors.centerIn: parent
                        running: !isSwapDone(details.order_status) && Qt.platform.os != "osx"
                        DefaultText {
                            anchors.centerIn: parent
                            font.pixelSize: 9
                            color: !details ? "white" : getStatusColor(details.order_status)
                            text_value: !details ? "" :
                                        visible ? getStatusStep(details.order_status) : ''
                        }
                    }
                }
                DefaultImage {
                    id: base_icon
                    source: General.coinIcon(!details ? atomic_app_primary_coin :
                                                        details.base_coin?? atomic_app_primary_coin)
                    Layout.preferredWidth: Style.textSize1
                    Layout.preferredHeight: Style.textSize1
                    Layout.alignment: Qt.AlignVCenter
                }
                DefaultText {
                    id: base_amount
                    text_value: !details ? "" :
                                General.formatCrypto("", details.base_amount, details.base_coin)
                    //details.base_amount_current_currency, API.app.settings_pg.current_currency
                    font.pixelSize: 11


                    Layout.fillHeight: true
                    Layout.preferredWidth: 110
                    verticalAlignment: Label.AlignVCenter
                    privacy: is_placed_order
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SwapIcon {
                        //visible: !status_text.visible
                        width: 30
                        height: 30
                        opacity: .6
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        top_arrow_ticker: !details ? atomic_app_primary_coin :
                                                     details.base_coin?? ""
                        bottom_arrow_ticker: !details ? atomic_app_primary_coin :
                                                        details.rel_coin?? ""
                    }
                }

                DefaultText {
                    id: rel_amount
                    text_value: !details ? "" :
                                General.formatCrypto("", details.rel_amount, details.rel_coin)
                    font.pixelSize: base_amount.font.pixelSize

                    Layout.fillHeight: true
                    Layout.preferredWidth: 110
                    verticalAlignment: Label.AlignVCenter
                    horizontalAlignment: Label.AlignRight
                    privacy: is_placed_order
                }
                DefaultImage {
                    id: rel_icon
                    source: General.coinIcon(!details ? atomic_app_primary_coin :
                                                        details.rel_coin?? atomic_app_secondary_coin)

                    width: base_icon.width
                    Layout.preferredWidth: Style.textSize1
                    Layout.preferredHeight: Style.textSize1
                    Layout.alignment: Qt.AlignVCenter
                }
                Item {
                    Layout.fillWidth: true 
                    Layout.fillHeight: true
                    opacity: .6
                    Qaterial.ColorIcon {
                        anchors.centerIn: parent
                        source:  expanded? Qaterial.Icons.chevronUp : Qaterial.Icons.chevronDown
                        iconSize: 14
                    }
                }

            }
            RowLayout {
                width: parent.width-40
                anchors.horizontalCenter: parent.horizontalCenter
                height: 20
                opacity: .6
                DexLabel {
                    Layout.fillWidth: true 
                    Layout.fillHeight: true 
                    verticalAlignment: Label.AlignVCenter
                    text: !details ? "" :
                                General.formatCrypto("", details.base_amount, details.base_coin)
                }
                DexLabel {
                    Layout.fillWidth: true 
                    Layout.fillHeight: true 
                    verticalAlignment: Label.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    text: !details ? "" :
                                General.formatCrypto("", details.rel_amount, details.rel_coin)
                }
            }
            RowLayout {
                width: parent.width-40
                anchors.horizontalCenter: parent.horizontalCenter
                height: 20
                opacity: .6
                DexLabel {
                    Layout.fillWidth: true 
                    Layout.fillHeight: true 
                    verticalAlignment: Label.AlignVCenter
                    text: "%1 %2".arg(API.app.settings_pg.current_currency).arg(details.base_amount_current_currency)
                }
                DexLabel {
                    Layout.fillWidth: true 
                    Layout.fillHeight: true 
                    verticalAlignment: Label.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    text: "%1 %2".arg(API.app.settings_pg.current_currency).arg(details.rel_amount_current_currency)
                }
            }
            RowLayout {
                width: parent.width-40
                anchors.horizontalCenter: parent.horizontalCenter
                height: 20
                opacity: .6
                DexLabel {
                    Layout.fillWidth: true 
                    Layout.fillHeight: true 
                    verticalAlignment: Label.AlignVCenter
                    text: !details ? "" : details.date?? ""
                }
                Item {
                    Layout.preferredWidth: 100
                    Layout.fillHeight: true 
                    visible: !details || details.recoverable === undefined ? false : details.recoverable && details.order_status !== "refunding"
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        spacing: 5
                        Qaterial.ColorIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: Qaterial.Icons.alert
                            iconSize: 15
                            color: Qaterial.Colors.amber
                        }
                        DexLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Refund "
                            color: Qaterial.Colors.amber
                        }
                    }
                    MouseArea {
                        id: refund_hover
                        anchors.fill: parent
                        hoverEnabled: true 
                    }
                    DefaultTooltip {
                        visible: (parent.visible && refund_hover.containsMouse) ?? false

                        contentItem: ColumnLayout {
                            DexLabel {
                                text_value: qsTr("Funds are recoverable")
                                font.pixelSize: Style.textSizeSmall4
                            }
                        }
                    }
                }
            }
             RowLayout {
                width: parent.width-30
                anchors.horizontalCenter: parent.horizontalCenter
                height: 30
                opacity: .6
                Qaterial.OutlineButton {
                    Layout.preferredWidth: 100
                    Layout.fillHeight: true 
                    bottomInset: 0
                    topInset: 0
                    outlinedColor: theme.redColor
                    visible: (!main_order.is_history? details.cancellable?? false : false)===true? (order_mouse_area.containsMouse || hovered)? true : false : false
                    onClicked: { if(details) cancelOrder(details.order_id) }
                    Row {
                        anchors.centerIn: parent
                        spacing: 5
                        Qaterial.ColorIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: Qaterial.Icons.close
                            iconSize: 17
                            color: theme.redColor
                        }
                        DexLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Cancel "
                            color: theme.redColor
                        }
                    }
                }
                
                Qaterial.OutlineButton {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true 
                    bottomInset: 0
                    topInset: 0
                    outlinedColor: Qaterial.Colors.gray
                    Row {
                        anchors.centerIn: parent
                        spacing: 5
                        Qaterial.ColorIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: Qaterial.Icons.eye
                            iconSize: 15
                            color: Qaterial.Colors.gray
                        }
                        DexLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Show "
                            color: Qaterial.Colors.gray
                        }
                    }
                    onClicked: {
                        order_modal.open()
                        order_modal.item.details = details
                    }
                }
                Item {
                    Layout.fillWidth: true 
                    Layout.fillHeight: true 
                    
                }
            }
        }
        
    }
}