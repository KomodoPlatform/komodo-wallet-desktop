import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
//import QtCharts 1.3

import "../Components"
import "../Constants"

// Portfolio
ColumnLayout {
    id: portfolio
    Layout.fillWidth: true
    Layout.fillHeight: true

    function reset() {
        updatePortfolio()
    }

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === General.idx_dashboard_portfolio
    }

    property var portfolio_coins: ([])

    function updatePortfolio() {
        portfolio_coins = API.get().get_portfolio_informations()
                            .sort((a, b) => parseFloat(b.balance_fiat) - parseFloat(a.balance_fiat))
        update_timer.running = true
    }

    Timer {
        id: update_timer
        running: false
        repeat: true
        interval: 5000
        onTriggered: {
            if(inCurrentPage()) updatePortfolio()
        }
    }

    function getColor(data) {
        return data.rates === null || data.rates[API.get().fiat].percent_change_24h === 0 ? Style.colorWhite4 :
                data.rates[API.get().fiat].percent_change_24h > 0 ? Style.colorGreen : Style.colorRed
    }

    // List header
    Rectangle {
        color: "transparent"

        Layout.alignment: Qt.AlignTop

        Layout.fillWidth: true

        height: 50

        // Coin
        DefaultText {
            id: coin_header
            anchors.left: parent.left
            anchors.leftMargin: 40

            text: qsTr("Coin")
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Balance
        DefaultText {
            id: balance_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.55

            text: qsTr("Balance")
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Value
        DefaultText {
            id: value_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.37

            text: qsTr("Value")
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Change 24h
        DefaultText {
            id: change_24h_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.21

            text: qsTr("Change 24h")
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Price
        DefaultText {
            id: price_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.05

            text: qsTr("Price")
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Line
        HorizontalLine {
            width: parent.width
            color: Style.colorWhite5
            anchors.bottom: parent.bottom
        }
    }

    // List
    ListView {
        id: list
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.vertical: ScrollBar {}

        model: portfolio_coins

        clip: true

        delegate: Rectangle {
            property bool hovered: false

            color: hovered ? Style.colorTheme5 : index % 2 == 0 ? Style.colorTheme6 : Style.colorTheme7
            width: portfolio.width
            height: 50

            // Click area
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: hovered = containsMouse
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button === Qt.RightButton) context_menu.popup()
                    else {
                        API.get().current_coin_info.ticker = model.modelData.ticker
                        dashboard.current_page = General.idx_dashboard_wallet
                    }
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
                anchors.leftMargin: coin_header.anchors.leftMargin

                source: General.image_path + "coins/" + model.modelData.ticker.toLowerCase() + ".png"
                fillMode: Image.PreserveAspectFit
                width: Style.textSize2
                anchors.verticalCenter: parent.verticalCenter
            }

            // Name
            DefaultText {
                anchors.left: icon.right
                anchors.leftMargin: 5

                text: General.fullCoinName(model.modelData.name, model.modelData.ticker)
                anchors.verticalCenter: parent.verticalCenter
            }

            // Balance
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: balance_header.anchors.rightMargin

                text: model.modelData.balance
                color: Style.colorWhite4
                anchors.verticalCenter: parent.verticalCenter
            }

            // Value
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: value_header.anchors.rightMargin

                text: General.formatFiat('', model.modelData.balance_fiat, API.get().fiat)
                color: Style.colorWhite4
                anchors.verticalCenter: parent.verticalCenter
            }

            // Change 24h
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: change_24h_header.anchors.rightMargin

                text: model.modelData.rates === null ? '-' :
                        ((model.modelData.rates[API.get().fiat].percent_change_24h > 0 ? '+' : '') +
                         (model.modelData.rates[API.get().fiat].percent_change_24h + '%'))
                color: getColor(model.modelData)
                anchors.verticalCenter: parent.verticalCenter
            }

            // Price
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: price_header.anchors.rightMargin

                text: General.formatFiat('', model.modelData.price, API.get().fiat)
                color: getColor(model.modelData)
                anchors.verticalCenter: parent.verticalCenter
            }

//            // Chart code for future
//            ChartView {
//                width: 200
//                height: 100
//                antialiasing: true
//                anchors.right: parent.right
//                anchors.rightMargin: price_header.anchors.rightMargin
//                anchors.verticalCenter: parent.verticalCenter
//                legend.visible: false

//                Component.onCompleted: {
//                    for(let i = 0; i < axes.length; ++i) {
//                        axes[i].visible = false
//                    }
//                }

//                backgroundColor: "transparent"
//                LineSeries {
//                    name: "LineSeries"
//                    XYPoint { x: 0; y: 0 }
//                    XYPoint { x: 1.1; y: 2.1 }
//                    XYPoint { x: 1.9; y: 3.3 }
//                    XYPoint { x: 2.1; y: 2.1 }
//                    XYPoint { x: 2.9; y: 4.9 }
//                    XYPoint { x: 3.4; y: 3.0 }
//                    XYPoint { x: 4.1; y: 3.3 }
//                }
//            }
        }
    }
}








/*##^##
Designer {
D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
