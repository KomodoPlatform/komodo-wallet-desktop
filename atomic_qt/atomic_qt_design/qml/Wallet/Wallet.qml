import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

    property string current_coin: ""

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
                    text: "3.333 " + current_coin
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

        ListView {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height

            model: MockAPI.app().enabled_coins

            delegate: Rectangle {
                property bool hovered: false

                color: current_coin === model.modelData.ticker ? Style.colorTheme2 : hovered ? Style.colorTheme4 : "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                width: coins_bar.width
                height: 50

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: current_coin = model.modelData.ticker
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
    D{i:0;autoSize:true;height:264;width:1200}
}
##^##*/
