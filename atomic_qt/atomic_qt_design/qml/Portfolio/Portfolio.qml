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

    readonly property int sort_by_name: 0
    readonly property int sort_by_ticker: 1
    readonly property int sort_by_value: 2
    readonly property int sort_by_balance: 3
    readonly property int sort_by_price: 4
    readonly property int sort_by_change: 5

    property int current_sort: sort_by_value
    property bool highest_first: true

    function reset() {
        updatePortfolio()
    }

    function onOpened() {
        updatePortfolio()
    }

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === General.idx_dashboard_portfolio
    }

    property var portfolio_coins: ([])

    function updatePortfolio() {
        portfolio_coins = API.get().get_portfolio_informations()

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

    // Top part
    Rectangle {
        color: "transparent"
        Layout.fillWidth: true
        height: 200

        ColumnLayout {
            anchors.centerIn: parent

            // Total Title
            DefaultText {
                Layout.topMargin: 50
                Layout.bottomMargin: 0
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("TOTAL")
                font.pointSize: Style.textSize
                color: Style.colorWhite5
            }

            // Total Balance
            DefaultText {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 30
                text: General.formatFiat("", API.get().balance_fiat_all, API.get().fiat)
                font.pointSize: Style.textSize4
            }
        }


        // Add button
        PlusButton {
            id: add_coin_button

            width: 50

            mouse_area.onClicked: enable_coin_modal.prepareAndOpen()

            anchors.right: parent.right
            anchors.rightMargin: parent.height * 0.5 - width * 0.5
            anchors.verticalCenter: parent.verticalCenter
        }

        // Search input
        TextField {
            id: input_coin_filter

            function reset() {
                visible = false
                text = ""
            }

            anchors.horizontalCenter: add_coin_button.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            placeholderText: qsTr("Search")
            selectByMouse: true

            width: 120
        }
    }


    // List header
    Rectangle {
        color: "transparent"

        Layout.alignment: Qt.AlignTop

        Layout.fillWidth: true

        height: 50

        // Line
        HorizontalLine {
            width: parent.width
            color: Style.colorWhite5
            anchors.top: parent.top
        }

        // Coin
        ColumnHeader {
            id: coin_header
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Coin")
            sort_type: sort_by_name
        }

        // Balance
        ColumnHeader {
            id: balance_header
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.3
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Balance")
            sort_type: sort_by_value
        }

        // Change 24h
        ColumnHeader {
            id: change_24h_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.27
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Change 24h")
            sort_type: sort_by_change
        }

        // Price
        ColumnHeader {
            id: price_header
            anchors.right: parent.right
            anchors.rightMargin: coin_header.anchors.leftMargin
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Price")
            sort_type: sort_by_price
        }

        // Line
        HorizontalLine {
            id: bottom_separator
            width: parent.width
            color: Style.colorWhite5
            anchors.bottom: parent.bottom
        }
    }

    // Transactions or loading
    Rectangle {
        id: loading
        color: "transparent"
        visible: portfolio_coins.length === 0
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            DefaultText {
                text: qsTr("Loading")
                Layout.alignment: Qt.AlignHCenter
                font.pointSize: Style.textSize2
            }

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // List
    ListView {
        id: list
        visible: portfolio_coins.length > 0
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.vertical: ScrollBar {}

        model: General.filterCoins(portfolio_coins, input_coin_filter.text)
                .sort((a, b) => {
            const order = highest_first ? 1 : -1
            switch(current_sort) {
                case sort_by_name:      return (b.name.toUpperCase() > a.name.toUpperCase() ? -1 : 1) * order
                case sort_by_ticker:    return (b.ticker > a.ticker ? -1 : 1) * order
                case sort_by_balance:   return (parseFloat(b.balance) - parseFloat(a.balance)) * order
                case sort_by_price:     return (parseFloat(b.price) - parseFloat(a.price)) * order
                case sort_by_value:     return (parseFloat(b.balance_fiat) - parseFloat(a.balance_fiat)) * order
                case sort_by_change:
                    let val_a = a.rates === null ? -9999999 : a.rates[API.get().fiat].percent_change_24h
                    let val_b = b.rates === null ? -9999999 : b.rates[API.get().fiat].percent_change_24h

                    return (val_b - val_a) * order
            }
        })

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
                anchors.leftMargin: 10

                text: model.modelData.name
                anchors.verticalCenter: parent.verticalCenter
            }

            // Balance
            DefaultText {
                id: balance_value
                anchors.left: parent.left
                anchors.leftMargin: balance_header.anchors.leftMargin

                text: model.modelData.balance
                color: Style.colorWhite4
                anchors.verticalCenter: parent.verticalCenter
            }

            // Ticker
            DefaultText {
                id: balance_ticker
                anchors.left: balance_value.right
                anchors.leftMargin: 5
                anchors.baseline: balance_value.baseline

                text: model.modelData.ticker
                color: Style.colorWhite6
                font.pointSize: Style.textSize * 0.9
            }

            // Value
            DefaultText {
                anchors.left: balance_ticker.right
                anchors.leftMargin: 10

                text: "(" + General.formatFiat('', model.modelData.balance_fiat, API.get().fiat) + ")"
                color: Style.colorWhite5
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
                color: Style.colorWhite6
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
