import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"

Item {
    id: rootVert
    SplitView.fillHeight: true
    SplitView.preferredWidth: isUltraLarge? 350 : 0
    SplitView.minimumWidth: 350
    Behavior on SplitView.preferredWidth {
        NumberAnimation {
            duration: 100
        }
    }
    visible: isUltraLarge

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        InnerBackground {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 2
            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    OrderbookHeader {
                        is_ask: true
                    }

                    ListView {
                        id: asks_view
                        anchors.topMargin: 40
                        anchors.fill: parent
                        model: API.app.trading_pg.orderbook.asks.proxy_mdl
                        clip: true
                        snapMode: ListView.SnapToItem
                        headerPositioning: ListView.OverlayHeader
                        Component.onCompleted: {
                            positionViewAtEnd()
                        }

                        delegate: Item {
                            width: rootVert.visible? asks_view.width:0
                            height: 36

                            AnimatedRectangle {
                                visible: mouse_area2.containsMouse //|| is_mine
                                width: parent.width
                                height: parent.height
                                color: Style.colorWhite1
                                opacity: 0.1

                                anchors.left: parent.left
                            }
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 6
                                height: 6
                                radius: width/2
                                x: 3
                                visible: is_mine
                                color: "#E31A93"
                            }

                            RowLayout {
                                id: row
                                width:  parent.width - 30
                                height: parent.height
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 10
                                DefaultText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: 90
                                    text: parseFloat(General.formatDouble(
                                              price, General.amountPrecision, true)).toFixed(8)
                                    font.pixelSize: Style.textSizeSmall1
                                    color: "#E31A93"

                                }
                                DefaultText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: 75
                                    text: parseFloat(quantity).toFixed(6)
                                    font.pixelSize: Style.textSizeSmall1
                                    horizontalAlignment: Label.AlignRight
                                    opacity: 1

                                }
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    onWidthChanged: progress2.width = ((depth * 100) * (width + 40)) / 100
                                    Rectangle {
                                        id: progress2
                                        height: 10
                                        radius: 101
                                        color: "#E31A93"
                                        width: 0
                                        Component.onCompleted: width =((depth * 100) * (parent.width + 40)) / 100
                                        opacity: 1.1-(index * 0.1)
                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 1000
                                            }
                                        }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                }
                                DefaultText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: 120
                                    text: parseFloat(total).toFixed(8)
                                    Behavior on rightPadding {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                    rightPadding: (is_mine) && (mouse_area2.containsMouse || cancel_button2.containsMouse) ? 30 : 0
                                    horizontalAlignment: Label.AlignRight
                                    font.pixelSize: Style.textSizeSmall1
                                    opacity: 1

                                }
                            }

                            DefaultMouseArea {
                                id: mouse_area2
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if(is_mine) return
                                    flick_scrollBar.position = 0
                                    selectOrder(true, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer)
                                    safe_exchange_flickable.flick(0, 5)
                                }
                            }
                            Qaterial.ColorIcon {
                                id: cancel_button_text2
                                property bool requested_cancel: false
                                visible: is_mine && !requested_cancel

                                source: Qaterial.Icons.close
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 1
                                anchors.right: parent.right
                                anchors.rightMargin:  mouse_area2.containsMouse || cancel_button2.containsMouse? 12 : 6
                                Behavior on iconSize {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }

                                iconSize: mouse_area2.containsMouse || cancel_button2.containsMouse? 16 : 0

                                color: cancel_button2.containsMouse ? Qaterial.Colors.red : mouse_area2.containsMouse? Style.colorText2 : Qaterial.Colors.red

                                DefaultMouseArea {
                                    id: cancel_button2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if(!is_mine) return

                                        cancel_button_text2.requested_cancel = true
                                        cancelOrder(uuid)
                                    }
                                }
                            }
                            HorizontalLine {
                                width: asks_view.width
                            }
                        }
                    }
                }

    //            HorizontalLine {
    //                Layout.fillWidth: true
    //            }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    OrderbookHeader {
                        is_ask: false
                    }
                    ListView {
                        id: bids_view
                        anchors.topMargin: 40
                        anchors.fill: parent
                        model: API.app.trading_pg.orderbook.bids.proxy_mdl
                        clip: true
                        snapMode: ListView.SnapToItem
                        headerPositioning: ListView.OverlayHeader
                        delegate: Item {
                            width: rootVert.visible? bids_view.width : 0
                            height: 36
                            AnimatedRectangle {
                                visible: mouse_area.containsMouse //|| is_mine
                                width: parent.width
                                height: parent.height
                                color: Style.colorWhite1
                                opacity: 0.1

                                anchors.right: parent.right
                            }
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 6
                                height: 6
                                radius: width/2
                                x: 3
                                visible: is_mine
                                color: Style.colorGreen
                            }
                            RowLayout {
                                id: row2
                                width: parent.width - 30
                                height: parent.height
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 10
                                DefaultText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: 90
                                    text: parseFloat(General.formatDouble(
                                              price, General.amountPrecision, true)).toFixed(8)
                                    font.family: 'Ubuntu'
                                    font.pixelSize: Style.textSizeSmall1
                                    color: Style.colorGreen
                                }
                                DefaultText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: 75
                                    text: parseFloat(quantity).toFixed(6)
                                    font.pixelSize: Style.textSizeSmall1
                                    horizontalAlignment: Label.AlignRight
                                }
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    onWidthChanged: progress.width = ((depth * 100) * (width + 40)) / 100
                                    Rectangle {
                                        id: progress
                                        height: 10
                                        radius: 101
                                        color: Style.colorGreen
                                        opacity: 1.1-(index * 0.1)
                                        width: 0
                                        Component.onCompleted: width =((depth * 100) * (parent.width + 40)) / 100
                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 1000
                                            }
                                        }

                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                DefaultText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: 120
                                    text: parseFloat(total).toFixed(8)
                                    Behavior on rightPadding {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                    rightPadding: (is_mine) && (mouse_area.containsMouse || cancel_button.containsMouse) ? 30 : 0
                                    horizontalAlignment: Label.AlignRight
                                    font.pixelSize: Style.textSizeSmall1
                                }
                            }
                            DefaultMouseArea {
                                id: mouse_area
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if(is_mine) return
                                    flick_scrollBar.position = 0
                                    selectOrder(false, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer)
                                }
                            }
                            Qaterial.ColorIcon {
                                id: cancel_button_text
                                property bool requested_cancel: false
                                visible: is_mine && !requested_cancel

                                source: Qaterial.Icons.close
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 1
                                anchors.right: parent.right
                                anchors.rightMargin:  mouse_area.containsMouse || cancel_button.containsMouse? 12 : 6
                                Behavior on iconSize {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }

                                iconSize: mouse_area.containsMouse || cancel_button.containsMouse? 16 : 0

                                color: cancel_button.containsMouse ? Qaterial.Colors.red : mouse_area.containsMouse? Style.colorText2 : Qaterial.Colors.red

                                DefaultMouseArea {
                                    id: cancel_button
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if(!is_mine) return

                                        cancel_button_text.requested_cancel = true
                                        cancelOrder(uuid)
                                    }
                                }
                            }
                            HorizontalLine {
                                width: bids_view.width
                            }
                        }
                    }
                }


            }
        }
    }


}
