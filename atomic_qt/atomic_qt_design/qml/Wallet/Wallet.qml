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
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            spacing: 30

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

            RowLayout {
                width: parent.width * 0.6

                Layout.topMargin: -10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                spacing: 50

                DefaultButton {
                    text: "Send"
                }

                DefaultButton {
                    text: "Receive"
                }

                DefaultButton {
                    text: "Swap"
                }
            }

            HorizontalLine {
                Layout.fillWidth: true
            }
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
                onClicked: console.log("add button")
            }

            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width * 0.5 - height * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
        }


        // Coins list
        ListView {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height

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
