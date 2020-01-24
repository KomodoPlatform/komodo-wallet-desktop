import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

    spacing: 0
    Layout.fillWidth: true

    // Left side, main
    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
        ColumnLayout {
            id: wallet_layout
            width: 600
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.bottom: parent.bottom

            spacing: 30

            // Balance texts
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                DefaultText {
                    text: "3.333 " + API.get().current_coin_info.ticker
                    Layout.alignment: Qt.AlignRight
                    font.pointSize: Style.textSize5
                }

                DefaultText {
                    text: "1.78 EUR"
                    Layout.topMargin: -15
                    Layout.rightMargin: 4
                    Layout.alignment: Qt.AlignRight
                    font.pointSize: Style.textSize2
                    color: Style.colorWhite4
                }
            }

            // Send, Receive buttons at top
            RowLayout {
                width: parent.width * 0.6

                Layout.topMargin: -10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                spacing: 50

                Button {
                    text: "Send"
                    leftPadding: parent.width * 0.075
                    rightPadding: parent.width * 0.075
                }

                Button {
                    text: "Receive"
                    leftPadding: parent.width * 0.075
                    rightPadding: parent.width * 0.075
                }

                Button {
                    text: "Swap"
                    leftPadding: parent.width * 0.075
                    rightPadding: parent.width * 0.075
                    onClicked: onClickedSwap()
                }
            }

            // Separator line
            HorizontalLine {
                Layout.fillWidth: true
            }

            DefaultText {
                visible: API.get().transactions.length === 0
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
        width: 125
        Layout.fillHeight: true
        color: Style.colorTheme7

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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: Math.min(contentItem.childrenRect.height, parent.height - coins_bar.width * 2)
            clip: true

            model: API.get().enabled_coins

            delegate: Rectangle {
                property bool hovered: false

                color: API.get().current_coin_info.ticker === model.modelData.ticker ? Style.colorTheme2 : hovered ? Style.colorTheme4 : "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                width: coins_bar.width
                height: 50

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: API.get().current_coin_info.ticker = model.modelData.ticker
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
