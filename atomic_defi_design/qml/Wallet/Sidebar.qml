import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants" as Constants
import App 1.0

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

        height: parent.height + 40

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
                color: DexTheme.walletSidebarLeftBorderColor
            }

            InnerBackground {
                id: search_row_bg
                anchors.top: parent.top
                anchors.topMargin: 30
                width: list_bg.width
                color: DexTheme.backgroundColor
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

                            source: Constants.General.image_path + "exchange-search.svg"

                            width: input_coin_filter.font.pixelSize; height: width

                            visible: false
                        }
                        DefaultColorOverlay {
                            id: search_button_overlay

                            anchors.fill: search_button
                            source: search_button
                            color: DexTheme.foregroundColor
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
                        font.pixelSize: Constants.Style.textSizeSmall3

                        background: null

                        Layout.fillWidth: true
                    }
                }
            }

            // Add button
            DexAppButton {
                id: add_coin_button
                onClicked: enable_coin_modal.open()
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.width * 0.5 - height * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                iconSource: Qaterial.Icons.plus
                font.pixelSize: 20
                leftPadding: 3
                rightPadding: 3

            }

            // Coins list
            InnerBackground {
                id: list_bg
                width: 145
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                content: DexListView {
                    id: list
                    implicitHeight: Math.min(contentItem.childrenRect.height, coins_bar.height - 250)
                    model: portfolio_coins
                    topMargin: 5
                    bottomMargin: 5

                    delegate: GradientRectangle {
                        width: list_bg.width - list_bg.border.width*2 - 6
                        height: 44
                        radius: Constants.Style.rectangleCornerRadius

                        start_color: api_wallet_page.ticker === ticker ? DexTheme.accentColor : mouse_area.containsMouse ? DexTheme.accentLightColor4: DexTheme.backgroundColor
                        end_color: api_wallet_page.ticker === ticker ? DexTheme.accentColor : mouse_area.containsMouse ? DexTheme.accentLightColor4: DexTheme.backgroundColor

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

                            source: Constants.General.coinIcon(ticker)
                            width: Constants.Style.textSizeSmall4*2
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: side_margin + scrollbar_margin

                            // Ticker
                            DexLabel {
                                Layout.alignment: Qt.AlignRight
                                text_value: ticker
                                color: api_wallet_page.ticker === ticker ? DexTheme.buttonColorTextEnabled : mouse_area.containsMouse ? DexTheme.foregroundColorLightColor2 : DexTheme.foregroundColor
                                font.pixelSize: text.length > 6 ? Constants.Style.textSizeSmall2 : Constants.Style.textSizeSmall4
                            }

                            DefaultTooltip {
                                visible: mouse_area.containsMouse

                                contentItem: ColumnLayout {
                                    DefaultText {
                                        text_value: name.replace(" (TESTCOIN)", "")
                                        font.pixelSize: Constants.Style.textSizeSmall4
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
        visible: DexTheme.walletSidebarShadowVisibility
        color: Constants.Style.colorWalletsSidebarDropShadow
        smooth: true
    }
}
