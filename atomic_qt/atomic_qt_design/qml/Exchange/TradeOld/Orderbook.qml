import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    property alias timer: orderbook_timer

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    property var orderbook_bids_model
    property var orderbook_asks_model

    function updateOrderbook() {
        const ob = API.get().get_orderbook()

        orderbook_bids_model = ob.bids
        orderbook_asks_model = ob.asks
    }

    Timer {
        id: orderbook_timer
        repeat: true
        interval: 5000
        onTriggered: updateOrderbook()
    }

    ColumnLayout {
        width: parent.width
        height: parent.height

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
                height: 44
                DefaultText {
                    text: qsTr("Asks")
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: Style.textSize2
                }
            }

            Item {
                Layout.fillWidth: true
                height: 44
                DefaultText {
                    text: qsTr("Bids")
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: Style.textSize2
                }
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        RowLayout {
            Layout.topMargin: -5
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true

            OrderbookListView {
                model: orderbook_asks_model
                value_color: Style.colorRed
            }

            VerticalLine {
                Layout.fillHeight: true
                color: Style.colorWhite8
            }

            OrderbookListView {
                model: orderbook_bids_model
                value_color: Style.colorGreen
            }
        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
