import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Coins bar at left side
Item {
    id: root

    function reset() {
        input_coin_filter_text = ''
        resetted()
    }

    signal resetted()

    property string input_coin_filter_text

    Layout.alignment: Qt.AlignLeft
    width: 175
    Layout.fillHeight: true

    // Background
    DefaultRectangle {
        id: background
        anchors.right: parent.right
        width: sidebar.width + parent.width

        DefaultGradient { }

        height: parent.height

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
                anchors.topMargin: anchors.bottomMargin
                color: Style.colorWhite12
            }

            InnerBackground {
                id: search_row_bg
                anchors.top: parent.top
                anchors.topMargin: 30
                width: list_bg.width
                anchors.horizontalCenter: list_bg.horizontalCenter

                radius: 100

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
                        Image {
                            id: search_button

                            source: General.image_path + "exchange-search.svg"

                            width: input_coin_filter.font.pixelSize; height: width

                            visible: false
                        }
                        ColorOverlay {
                            id: search_button_overlay

                            anchors.fill: search_button
                            source: search_button
                            color: Style.colorText
                        }
                    }

                    // Search input
                    DefaultTextField {
                        id: input_coin_filter

                        Connections {
                            target: root

                            function onResetted() {
                                input_coin_filter.text = ""
                            }
                        }

                        onTextChanged: input_coin_filter_text = text
                        font.pixelSize: Style.textSizeSmall3

                        background: null

                        selectByMouse: true
                        Layout.fillWidth: true
                    }
                }
            }

            // Add button
            PlusButton {
                id: add_coin_button
                onClicked: enable_coin_modal.prepareAndOpen()

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

                    model: General.filterCoins(API.get().enabled_coins, input_coin_filter_text)

                    delegate: Rectangle {
                        color: list_bg.color
                        width: list_bg.width - list_bg.border.width*2 - 2
                        height: 44
                        radius: Style.rectangleCornerRadius

                        LinearGradient {
                            visible: API.get().current_coin_info.ticker === model.modelData.ticker || mouse_area.containsMouse
                            anchors.fill: parent
                            source: parent

                            start: Qt.point(0, 0)
                            end: Qt.point(parent.width, 0)

                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: API.get().current_coin_info.ticker === model.modelData.ticker ? Style.colorCoinListHighlightGradient1 : Style.colorCoinListHighlightGradient1
                                }
                                GradientStop {
                                    position: 1.0
                                    color: API.get().current_coin_info.ticker === model.modelData.ticker ? Style.colorCoinListHighlightGradient2 : Style.colorWhite8
                                }
                            }
                        }

                        // Click area
                        MouseArea {
                            id: mouse_area
                            anchors.fill: parent
                            hoverEnabled: true

                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: {
                                if (mouse.button === Qt.RightButton) context_menu.popup()
                                else API.get().current_coin_info.ticker = model.modelData.ticker

                                main.send_modal.reset()
                            }
                            onPressAndHold: {
                                if (mouse.source === Qt.MouseEventNotSynthesized) context_menu.popup()
                            }
                        }

                        // Right click menu
                        Menu {
                            id: context_menu
                            Action {
                                text: API.get().empty_string + (qsTr("Disable %1", "TICKER").arg(model.modelData.ticker))
                                onTriggered: API.get().disable_coins([model.modelData.ticker])
                                enabled: General.canDisable(model.modelData.ticker)
                            }
                        }

                        readonly property double side_margin: 25

                        // Icon
                        Image {
                            id: icon
                            anchors.left: parent.left
                            anchors.leftMargin: side_margin - scrollbar_margin

                            source: General.coinIcon(model.modelData.ticker)
                            fillMode: Image.PreserveAspectFit
                            width: Style.textSizeSmall4*2
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: side_margin + scrollbar_margin

//                            spacing: -3
//                            // Name
//                            DefaultText {
//                                Layout.alignment: Qt.AlignRight
//                                text_value: API.get().empty_string + (model.modelData.name.replace(" (TESTCOIN)", ""))
//                                font.pixelSize: text.length > 15 ? Style.textSizeVerySmall8 : text.length > 12 ? Style.textSizeVerySmall9 : Style.textSizeSmall1
//                            }

                            // Ticker
                            DefaultText {
                                Layout.alignment: Qt.AlignRight
                                text_value: API.get().empty_string + (model.modelData.ticker)
                                font.pixelSize: text.length > 15 ? Style.textSizeVerySmall8 : text.length > 12 ? Style.textSizeVerySmall9 : Style.textSizeSmall1
//                                font.pixelSize: Style.textSizeSmall1
//                                color: Style.colorThemePassive
                            }

                            ToolTip {
                                visible: mouse_area.containsMouse
                                background: FloatingBackground { auto_set_size: false }
                                contentItem:  DefaultText {
                                    text_value: API.get().empty_string + (model.modelData.name.replace(" (TESTCOIN)", ""))
                                    font.pixelSize: Style.textSizeSmall4
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
