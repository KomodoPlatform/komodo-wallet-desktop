import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Coins bar at left side
Item {
    id: root

    function reset() {
        input_coin_filter.reset()
    }

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

            RowLayout {
                id: search_row
                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 15
                anchors.rightMargin: anchors.leftMargin

                spacing: 10

                // Search button
                Rectangle {
                    color: "transparent"
                    width: search_button.width
                    height: search_button.height
                    Image {
                        id: search_button

                        source: General.image_path + "exchange-search.svg"

                        width: 16; height: width

                        visible: false
                    }
                    ColorOverlay {
                        id: search_button_overlay

                        anchors.fill: search_button
                        source: search_button
                        color: Style.colorWhite1
                    }
                }

                // Search input
                DefaultTextField {
                    id: input_coin_filter

                    function reset() {
                        text = ""
                    }

                    selectByMouse: true
                    Layout.fillWidth: true
                }
            }

            // Add button
            PlusButton {
                id: add_coin_button
                onClickedFunc: enable_coin_modal.prepareAndOpen

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

                content: ListView {
                    id: list
                    ScrollBar.vertical: DefaultScrollBar {}
                    implicitWidth: contentItem.childrenRect.width
                    implicitHeight: Math.min(contentItem.childrenRect.height, coins_bar.height - 250)

                    clip: true

                    model: General.filterCoins(API.get().enabled_coins, input_coin_filter.text)

                    delegate: Rectangle {
                        color: API.get().current_coin_info.ticker === model.modelData.ticker ? Style.colorTheme5 : mouse_area.containsMouse ? Style.colorTheme6 : "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: list_bg.width
                        height: 50
                        radius: Style.rectangleCornerRadius

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

                        // Icon
                        Image {
                            id: icon
                            anchors.left: parent.left
                            anchors.leftMargin: 15

                            source: General.image_path + "coins/" + model.modelData.ticker.toLowerCase() + ".png"
                            fillMode: Image.PreserveAspectFit
                            width: Style.textSizeSmall4*2
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: icon.anchors.leftMargin

                            spacing: -3
                            // Name
                            DefaultText {
                                Layout.alignment: Qt.AlignRight
                                text: API.get().empty_string + (model.modelData.name.replace(" (TESTCOIN)", ""))
                                font.pixelSize: text.length > 15 ? Style.textSizeVerySmall8 : text.length > 12 ? Style.textSizeVerySmall9 : Style.textSizeSmall2
                            }

                            // Ticker
                            DefaultText {
                                Layout.alignment: Qt.AlignRight
                                text: API.get().empty_string + (model.modelData.ticker)
                                font.pixelSize: Style.textSizeSmall2
                                color: Style.colorThemePassive
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
        color: "#B0000000"
        smooth: true
    }
}
