import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Coins bar at left side
Item {
    id: root

    function reset() {
        resetted()
    }

    signal resetted()

    Layout.alignment: Qt.AlignLeft
    width: 175
    Layout.fillHeight: true
    Layout.topMargin: -40 

    // Background
    SidebarPanel {
        id: background
        anchors.right: parent.right
        width: sidebar.width + parent.width

        height: parent.height+40

        // Panel contents
        Item {
            id: coins_bar
            width: 175
            height: parent.height
            anchors.right: parent.right

            VerticalLine {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1
                opacity: .3
                anchors.topMargin: anchors.bottomMargin
                color: theme.backgroundColorDeep
            }

            InnerBackground {
                id: search_row_bg
                anchors.top: parent.top
                anchors.topMargin: 30
                width: list_bg.width
                color: theme.backgroundColor
                anchors.horizontalCenter: list_bg.horizontalCenter

                content: RowLayout {
                    id: search_row

                    width: search_row_bg.width

                    // Search button
                    Item {
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: search_button.width
                        Layout.rightMargin: -Layout.leftMargin
                        width: search_button.width
                        height: search_button.height
                        DefaultImage {
                            id: search_button

                            source: General.image_path + "exchange-search.svg"

                            width: input_coin_filter.font.pixelSize; height: width

                            visible: false
                        }
                        DefaultColorOverlay {
                            id: search_button_overlay

                            anchors.fill: search_button
                            source: search_button
                            color: theme.foregroundColor
                        }
                    }

                    // Search input
                    DefaultTextField {
                        id: input_coin_filter

                        Connections {
                            target: root

                            function onResetted() {
                                if(input_coin_filter.text === "") resetCoinFilter()
                                else input_coin_filter.text = ""

                                //portfolio_coins.sort_by_name(true)
                            }
                        }

                        onTextChanged: portfolio_coins.setFilterFixedString(text)
                        font.pixelSize: Style.textSizeSmall3

                        background: null

                        Layout.fillWidth: true
                    }
                }
            }

            // Add button
            PlusButton {
                id: add_coin_button
                onClicked: enable_coin_modal.open()

                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.width * 0.5 - height * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Coins list
            InnerBackground {
                id: list_bg
                width: 145
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                content: DefaultListView {
                    id: list
                    implicitHeight: Math.min(contentItem.childrenRect.height, coins_bar.height - 250)

                    model: portfolio_coins

                    delegate: GradientRectangle {
                        width: list_bg.width - list_bg.border.width*2 - 2
                        height: 44
                        radius: Style.rectangleCornerRadius

                        start_color: Style.applyOpacity(Style.colorCoinListHighlightGradient)
                        end_color: api_wallet_page.ticker === ticker ? theme.hightlightColor : mouse_area.containsMouse ? Style.colorWhite8 : start_color

                        // Click area
                        DefaultMouseArea {
                            id: mouse_area
                            anchors.fill: parent
                            hoverEnabled: true

                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: {
                                if(!can_change_ticker) return

                                if (mouse.button === Qt.RightButton) context_menu.popup()
                                else api_wallet_page.ticker = ticker
                            }
                            onPressAndHold: {
                                if(!can_change_ticker) return

                                if (mouse.source === Qt.MouseEventNotSynthesized) context_menu.popup()
                            }
                        }

                        // Right click menu
                        CoinMenu {
                            id: context_menu
                        }

                        readonly property double side_margin: 16

                        // Icon
                        DefaultImage {
                            id: icon
                            anchors.left: parent.left
                            anchors.leftMargin: side_margin - scrollbar_margin

                            source: General.coinIcon(ticker)
                            width: Style.textSizeSmall4*2
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: side_margin + scrollbar_margin

                            // Ticker
                            DefaultText {
                                Layout.alignment: Qt.AlignRight
                                text_value: ticker
                                font.pixelSize: text.length > 6 ? Style.textSizeSmall2 : Style.textSizeSmall4
                            }

                            DefaultTooltip {
                                visible: mouse_area.containsMouse

                                contentItem: ColumnLayout {
                                    DefaultText {
                                        text_value: name.replace(" (TESTCOIN)", "")
                                        font.pixelSize: Style.textSizeSmall4
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    DropShadow {
        anchors.fill: background
        source: background
        cached: false
        horizontalOffset: 0
        verticalOffset: 0
        radius: 32
        samples: 32
        spread: 0
        color: Style.colorWalletsSidebarDropShadow
        smooth: true
    }
}
