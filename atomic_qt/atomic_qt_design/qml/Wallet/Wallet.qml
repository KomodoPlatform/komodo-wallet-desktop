import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

    function fillCoinList() {
        coin_list.clear()
        coin_list.append(MockAPI.getAtomicApp().enabled_coins)
    }

    Component.onCompleted: fillCoinList()

    property int current_page: General.idx_exchange_trade

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
                    text: "3.333 KMD"
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
        width: 400
        Layout.fillHeight: true
        color: Style.colorTheme7

        ListView {
            anchors.fill: parent

            model: ListModel {
                id: coin_list
            }

            delegate: Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Layout.fillWidth: true

                spacing: 10

                Image {
                    source: General.image_path + "coins/" + ticker.toLowerCase() + ".png"
                    fillMode: Image.PreserveAspectFit
                    width: Style.textSize2
                    anchors.verticalCenter: parent.verticalCenter
                }

                DefaultText {
                    text: ticker
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
