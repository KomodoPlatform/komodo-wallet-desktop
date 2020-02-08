import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

    // Local
    function onClickedSwap() {
        dashboard.current_page = General.idx_dashboard_exchange
        exchange.current_page = General.idx_exchange_trade
        exchange.changeBase(API.get().current_coin_info.ticker)
    }

    readonly property double button_margin: 0.05
    spacing: 0
    Layout.fillWidth: true

    // Left side, main
    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
        ColumnLayout {
            id: wallet_layout
            width: 900
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.bottom: parent.bottom

            spacing: 30

            // Balance texts
            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                ColumnLayout {
                    id: balance_layout
                    DefaultText {
                        text: General.formatCrypto("", API.get().current_coin_info.balance, API.get().current_coin_info.ticker)
                        Layout.alignment: Qt.AlignRight
                        font.pointSize: Style.textSize5
                    }

                    DefaultText {
                        text: General.formatFiat("", API.get().current_coin_info.fiat_amount, API.get().fiat)
                        Layout.topMargin: -15
                        Layout.rightMargin: 4
                        Layout.alignment: Qt.AlignRight
                        font.pointSize: Style.textSize2
                        color: Style.colorWhite4
                    }
                }
                Image {
                    source: General.coinIcon(API.get().current_coin_info.ticker)
                    Layout.leftMargin: 10
                    Layout.preferredHeight: balance_layout.childrenRect.height
                    Layout.preferredWidth: Layout.preferredHeight
                }
            }

            // Send, Receive buttons at top
            RowLayout {
                width: parent.width * 0.6

                Layout.topMargin: -10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                spacing: 50

                Button {
                    text: qsTr("Send")
                    leftPadding: parent.width * button_margin
                    rightPadding: leftPadding
                    onClicked: send_modal.open()
                }

                SendModal {
                    id: send_modal
                }

                Button {
                    text: qsTr("Receive")
                    leftPadding: parent.width * button_margin
                    rightPadding: leftPadding
                    onClicked: receive_modal.open()
                }

                ReceiveModal {
                    id: receive_modal
                }

                Button {
                    text: qsTr("Swap")
                    leftPadding: parent.width * button_margin
                    rightPadding: leftPadding
                    onClicked: onClickedSwap()
                }

                Button {
                    text: qsTr("Claim Rewards")
                    leftPadding: parent.width * button_margin
                    rightPadding: leftPadding

                    visible: API.get().current_coin_info.is_claimable === true
                    onClicked: claim_rewards_modal.open()
                }

                ClaimRewardsModal {
                    id: claim_rewards_modal
                }
            }

            // Separator line
            HorizontalLine {
                Layout.fillWidth: true
            }

            DefaultText {
                visible: API.get().current_coin_info.transactions.length === 0
                text: qsTr("No transactions")
                font.pointSize: Style.textSize
                color: Style.colorWhite4
                Layout.alignment: Qt.AlignHCenter
            }

            Transactions {
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: Math.min(contentItem.childrenRect.height, wallet.height*0.5)
            }
            implicitHeight: Math.min(contentItem.childrenRect.height, wallet.height*0.5)
        }
    }

    // Coins bar at right side
    Rectangle {
        id: coins_bar
        Layout.alignment: Qt.AlignRight
        width: 150
        Layout.fillHeight: true
        color: Style.colorTheme7

        // Balance
        DefaultText {
            anchors.top: parent.top
            anchors.topMargin: search_button.anchors.topMargin * 0.5 - font.pointSize * 0.5
            anchors.horizontalCenter: parent.horizontalCenter

            text: General.formatFiat("", API.get().balance_fiat_all, API.get().fiat)
        }

        // Search button
        Image {
            id: search_button

            source: General.image_path + "exchange-search.svg"

            width: 32; height: width

            anchors.top: parent.top
            anchors.topMargin: parent.width * 0.5 - height * 0.5
            anchors.horizontalCenter: parent.horizontalCenter

            visible: false
        }
        ColorOverlay {
            id: search_button_overlay
            property bool hovered: false

            anchors.fill: search_button
            source: search_button
            color: search_button_overlay.hovered || input_coin_filter.visible ? Style.colorWhite1 : Style.colorWhite4

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: search_button_overlay.hovered = containsMouse
                onClicked: {
                    input_coin_filter.text = ""
                    input_coin_filter.visible = !input_coin_filter.visible
                    if(input_coin_filter.visible)
                        input_coin_filter.focus = true
                }
            }
        }

        // Search input
        TextField {
            id: input_coin_filter

            anchors.top: search_button.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            placeholderText: qsTr("Search")
            selectByMouse: true

            visible: false

            width: parent.width * 0.8
        }

        // Add button
        Rectangle {
            id: add_coin_button

            width: 32; height: width
            property bool hovered: false
            color: "transparent"
            border.color: hovered ? Style.colorTheme0 : Style.colorTheme3
            border.width: 2
            radius: 100

            Rectangle {
                width: parent.border.width
                height: parent.width * 0.5
                radius: parent.radius
                color: parent.border.color
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width * 0.5
                height: parent.border.width
                radius: parent.radius
                color: parent.border.color
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: add_coin_button.hovered = containsMouse
                onClicked: enable_coin_modal.open()
            }

            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width * 0.5 - height * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Modals
        EnableCoinModal {
            id: enable_coin_modal
            anchors.centerIn: Overlay.overlay
        }

        // Coins list
        ListView {
            ScrollBar.vertical: ScrollBar {}
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: Math.min(contentItem.childrenRect.height, parent.height - coins_bar.width * 2)
            clip: true

            model: General.filterCoins(API.get().enabled_coins, input_coin_filter.text)

            delegate: Rectangle {
                property bool hovered: false

                color: API.get().current_coin_info.ticker === model.modelData.ticker ? Style.colorTheme2 : hovered ? Style.colorTheme4 : "transparent"
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

                        send_modal.reset()
                    }
                    onPressAndHold: {
                        if (mouse.source === Qt.MouseEventNotSynthesized) context_menu.popup()
                    }
                }

                // Right click menu
                Menu {
                    id: context_menu
                    Action {
                        text: "Disable " + model.modelData.ticker
                        onTriggered: API.get().disable_coins([model.modelData.ticker])
                        enabled: API.get().enabled_coins.length > 2
                    }
                }

                // Icon
                Image {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: 20

                    source: General.image_path + "coins/" + model.modelData.ticker.toLowerCase() + ".png"
                    fillMode: Image.PreserveAspectFit
                    width: Style.textSize2
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Name
                DefaultText {
                    anchors.left: icon.right
                    anchors.leftMargin: 5

                    text: model.modelData.ticker
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
