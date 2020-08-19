import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import QtCharts 2.3

import "../Components"
import "../Constants"

// Portfolio
ColumnLayout {
    id: portfolio
    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property int sort_by_name: 0
    readonly property int sort_by_value: 1
    readonly property int sort_by_change: 3
    readonly property int sort_by_trend: 4
    readonly property int sort_by_price: 5

    property int current_sort: sort_by_value
    property bool ascending: false

    function reset() { }

    function onOpened() { }

    function updateChart(chart, historical) {
        chart.removeAllSeries()

        let i
        if(historical.length > 0) {
            // Fill chart
            let series = chart.createSeries(ChartView.SeriesTypeSpline, "Price", chart.axes[0], chart.axes[1]);

            series.style = Qt.SolidLine
            series.color = Style.colorTheme1

            let min = 999999999
            let max = -999999999
            for(i = 0; i < historical.length; ++i) {
                let price = historical[i].price
                series.append(i / historical.length, historical[i].price)
                min = Math.min(min, price)
                max = Math.max(max, price)
            }

            chart.axes[1].min = min * 0.99
            chart.axes[1].max = max * 1.01
        }

        // Hide background grid
        for(i = 0; i < chart.axes.length; ++i)
            chart.axes[i].visible = false
    }

    // Top part
    Item {
        Layout.fillWidth: true
        height: 200

        ColumnLayout {
            id: top_layout
            anchors.centerIn: parent

            // Total Title
            DefaultText {
                Layout.topMargin: 50
                Layout.bottomMargin: 0
                Layout.alignment: Qt.AlignHCenter
                text_value: API.get().settings_pg.empty_string + (qsTr("TOTAL"))
                font.pixelSize: Style.textSize
                color: Style.colorWhite5
            }

            // Total Balance
            DefaultText {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 30
                text_value: API.get().settings_pg.empty_string + (General.formatFiat("", API.get().balance_fiat_all, API.get().settings_pg.current_currency))
                font.pixelSize: Style.textSize4
                privacy: true
            }
        }

        MouseArea {
            anchors.fill: top_layout

            onClicked: {
                const current_fiat = API.get().settings_pg.current_currency
                const available_fiats = API.get().settings_pg.get_available_currencies()
                const current_index = available_fiats.indexOf(current_fiat)
                const next_index = (current_index + 1) % available_fiats.length
                const next_fiat = available_fiats[next_index]
                API.get().settings_pg.current_currency = next_fiat
            }
        }

        // Add button
        PlusButton {
            id: add_coin_button
            onClicked: enable_coin_modal.prepareAndOpen()

            anchors.right: parent.right
            anchors.rightMargin: parent.height * 0.5 - width * 0.5
            anchors.verticalCenter: parent.verticalCenter
        }

        // Search input
        DefaultTextField {
            id: input_coin_filter

            function reset() {
                visible = false
                text = ""
            }

            anchors.horizontalCenter: add_coin_button.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            placeholderText: API.get().settings_pg.empty_string + (qsTr("Search"))
            selectByMouse: true

            onTextChanged: {
                API.get().portfolio_pg.portfolio_mdl.portfolio_proxy_mdl.setFilterFixedString(text)
            }

            width: 120
        }
    }


    // List header
    Item {
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
            icon_at_left: true
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter

            text: API.get().settings_pg.empty_string + (qsTr("Coin"))
            sort_type: sort_by_name
        }

        // Balance
        ColumnHeader {
            id: balance_header
            icon_at_left: true
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.265
            anchors.verticalCenter: parent.verticalCenter

            text: API.get().settings_pg.empty_string + (qsTr("Balance"))
            sort_type: sort_by_value
        }

        // Change 24h
        ColumnHeader {
            id: change_24h_header
            icon_at_left: false
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.37
            anchors.verticalCenter: parent.verticalCenter

            text: API.get().settings_pg.empty_string + (qsTr("Change 24h"))
            sort_type: sort_by_change
        }

        // 7-day Trend
        ColumnHeader {
            id: trend_7d_header
            icon_at_left: false
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.24
            anchors.verticalCenter: parent.verticalCenter

            text: API.get().settings_pg.empty_string + (qsTr("Trend 7d"))
            sort_type: sort_by_trend
        }

        // Price
        ColumnHeader {
            id: price_header
            icon_at_left: false
            anchors.right: parent.right
            anchors.rightMargin: coin_header.anchors.leftMargin
            anchors.verticalCenter: parent.verticalCenter

            text: API.get().settings_pg.empty_string + (qsTr("Price"))
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

    // List
    DefaultListView {
        id: list
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true

        model: portfolio_coins

        delegate: Rectangle {
            color: mouse_area.containsMouse ? Style.colorTheme5 : index % 2 == 0 ? Style.colorTheme6 : Style.colorTheme7
            width: portfolio.width
            height: 50

            // Click area
            MouseArea {
                id: mouse_area
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button === Qt.RightButton) context_menu.popup()
                    else {
                        API.get().current_coin_info.ticker = ticker
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
                    text: API.get().settings_pg.empty_string + (qsTr("Disable %1", "TICKER").arg(ticker))
                    onTriggered: API.get().disable_coins([ticker])
                    enabled: General.canDisable(ticker)
                }
            }

            // Icon
            DefaultImage {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: coin_header.anchors.leftMargin

                source: General.coinIcon(ticker)
                fillMode: Image.PreserveAspectFit
                width: Style.textSize2
                anchors.verticalCenter: parent.verticalCenter
            }

            // Name
            DefaultText {
                anchors.left: icon.right
                anchors.leftMargin: 10
                text_value: API.get().settings_pg.empty_string + (name)
                anchors.verticalCenter: parent.verticalCenter
            }

            // Balance
            DefaultText {
                id: balance_value
                anchors.left: parent.left
                anchors.leftMargin: balance_header.anchors.leftMargin

                text_value: API.get().settings_pg.empty_string + (General.formatCrypto("", balance, ticker,  main_currency_balance, API.get().settings_pg.current_currency))
                color: Style.colorWhite4
                anchors.verticalCenter: parent.verticalCenter
                privacy: true
            }

            // Change 24h
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: change_24h_header.anchors.rightMargin

                text_value: {
                    const v = parseFloat(change_24h)
                    return API.get().settings_pg.empty_string + (v === 0 ? '-' : General.formatPercent(v))
                }
                color: Style.getValueColor(change_24h)
                anchors.verticalCenter: parent.verticalCenter
            }

            // Price
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: price_header.anchors.rightMargin

                text_value: API.get().settings_pg.empty_string + (General.formatFiat('', main_currency_price_for_one_unit, API.get().settings_pg.current_currency))
                color: Style.colorThemeDarkLight
                anchors.verticalCenter: parent.verticalCenter
            }

            // 7d Trend
            ChartView {
                property var historical: trend_7d
                id: chart
                width: 200
                height: 100
                antialiasing: true
                anchors.right: parent.right
                anchors.rightMargin: trend_7d_header.anchors.rightMargin - width * 0.4
                anchors.verticalCenter: parent.verticalCenter
                legend.visible: false

                onHistoricalChanged: updateChart(chart, historical)

                backgroundColor: "transparent"
            }
        }
    }
}
