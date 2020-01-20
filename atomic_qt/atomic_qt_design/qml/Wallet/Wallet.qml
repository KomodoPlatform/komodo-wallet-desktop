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

    // Left side, main
    ColumnLayout {
        width: parent.width - coins_bar.width
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        spacing: 30

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            DefaultText {
                text: "3.333 KMC"
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
            id: buttons_row
            Layout.topMargin: -10
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            spacing: 50

            Button {
                text: "Send"
                Layout.fillWidth: true
            }

            Button {
                text: "Receive"
                Layout.fillWidth: true
            }

            Button {
                text: "Swap"
                Layout.fillWidth: true
            }
        }

        HorizontalLine {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            width: buttons_row.width * 1.25
            x: -(width - buttons_row.width) * 0.5
            Layout.fillWidth: true
        }

    }

    // Coins bar at right side
    Rectangle {
        id: coins_bar
        width: 100
        height: parent.height
        color: Style.colorTheme5
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:150}
}
##^##*/
