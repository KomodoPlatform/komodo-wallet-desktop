import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

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
        width: 100
        Layout.fillHeight: true
        color: Style.colorTheme7
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:1200}
}
##^##*/
