import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Coins bar at left side
Rectangle {
    id: coins_bar

    function reset() {
        input_coin_filter.reset()
    }

    Layout.alignment: Qt.AlignLeft
    width: 150
    Layout.fillHeight: true
    color: Style.colorTheme7

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
                property bool hovered: false

                anchors.fill: search_button
                source: search_button
                color: search_button_overlay.hovered || input_coin_filter.visible ? Style.colorWhite1 : Style.colorWhite4
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

        width: 32

        mouse_area.onClicked: enable_coin_modal.prepareAndOpen()

        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.width * 0.5 - height * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Coins list
    ListView {
        ScrollBar.vertical: DefaultScrollBar {}
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: contentItem.childrenRect.width

        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: Math.min(contentItem.childrenRect.height, parent.height - 250)

        clip: true

        model: General.filterCoins(API.get().enabled_coins, input_coin_filter.text)

        delegate: Rectangle {
            property bool hovered: false

            color: API.get().current_coin_info.ticker === model.modelData.ticker ? Style.colorTheme5 : hovered ? Style.colorTheme6 : "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            width: coins_bar.width
            height: 50

            // Click area
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: hovered = containsMouse

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
                width: (Style.textSize2 + Style.textSize3)*0.5
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
                    font.pixelSize: text.length > 12 ? Style.textSizeSmall : Style.textSizeSmall3
                }

                // Ticker
                DefaultText {
                    Layout.alignment: Qt.AlignRight
                    text: API.get().empty_string + (model.modelData.ticker)
                    font.pixelSize: Style.textSizeSmall4
                    color: Style.colorDarkText
                }
            }
        }
    }
}
