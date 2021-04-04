 import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtWebEngine 1.8

import QtGraphicalEffects 1.0
import QtCharts 2.3
import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"

// Portfolio
Item {
    id: portfolio
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.bottomMargin: 40
    Layout.margins: 40
    function getPercent(fiat_amount) {
        const portfolio_balance = parseFloat(API.app.portfolio_pg.balance_fiat_all)
        if(fiat_amount <= 0 || portfolio_balance <= 0) return "-"

        return General.formatPercent((100 * fiat_amount/portfolio_balance).toFixed(2), false)
    }

    property string total: General.formatFiat(
                               "", API.app.portfolio_pg.balance_fiat_all,
                               API.app.settings_pg.current_currency)
    readonly property int sort_by_name: 0
    readonly property int sort_by_value: 1
    readonly property int sort_by_change: 3
    readonly property int sort_by_trend: 4
    readonly property int sort_by_price: 5
    property string currentValue: ""
    property string currentTotal: ""

    property int current_sort: sort_by_value
    property bool ascending: false

    function applyCurrentSort() {
        // Apply the sort
        switch (current_sort) {
        case sort_by_name:
            portfolio_coins.sort_by_name(ascending)
            break
        case sort_by_value:
            portfolio_coins.sort_by_currency_balance(ascending)
            break
        case sort_by_price:
            portfolio_coins.sort_by_currency_unit(ascending)
            break
        case sort_by_trend:
        case sort_by_change:
            portfolio_coins.sort_by_change_last24h(ascending)
            break
        }
    }
    function refresh() {
        pieSeries.clear()
        for (var i = 0; i < portfolio_mdl.pie_chart_proxy_mdl.rowCount(); i++) {
            let data = portfolio_mdl.pie_chart_proxy_mdl.get(i)
            addItem(data)
        }
    }
    Timer {
        id: pieTimer
        interval: 500
        onTriggered: refresh()
    }
    onTotalChanged: {
        refresh()
        pieTimer.restart()
    }

    Component.onCompleted: {
        reset()
    }

    function reset() {
        // Reset the coin name filter
        input_coin_filter.reset()
    }

    function updateChart(chart, historical, color) {
        chart.removeAllSeries()

        let i
        if (historical.length > 0) {
            // Fill chart
            let series = chart.createSeries(ChartView.SeriesTypeSpline,
                                            "Price", chart.axes[0],
                                            chart.axes[1])

            series.style = Qt.SolidLine
            series.color = color

            let min = 999999999
            let max = -999999999
            for (i = 0; i < historical.length; ++i) {
                let price = historical[i]
                series.append(i / historical.length, historical[i])
                min = Math.min(min, price)
                max = Math.max(max, price)
            }

            chart.axes[1].min = min * 0.99
            chart.axes[1].max = max * 1.01
        }

        // Hide background grid
        for (i = 0; i < chart.axes.length; ++i)
            chart.axes[i].visible = false
    }

    function addItem(value) {

        var item = pieSeries.append(value.ticker, value.main_currency_balance)
        item.labelColor = 'white'
        item.color = Style.getCoinColor(value.ticker)
        item.borderColor = theme.backgroundColor
        item.borderWidth = 14
        item.holeSize = 1
        item.labelFont = theme.textType.body2
        item.hovered.connect(function (state) {
            if (state) {
                item.exploded = true
                item.explodeDistanceFactor = 0.01
                item.labelVisible = true
                portfolio.currentTotal = "$ " + value.main_currency_balance
                portfolio.currentValue = value.balance + " " + item.label
                item.color = Qt.lighter(Style.getCoinColor(value.ticker))
            } else {
                item.exploded = false
                item.labelVisible = false
                item.explodeDistanceFactor = 0.01
                portfolio.currentValue = ""
                portfolio.currentTotal = ""
                item.color = Style.getCoinColor(value.ticker)
            }
        })
    }

    Flickable {
        anchors.fill: parent
        anchors.topMargin: 90
        contentHeight: _column.height
        clip: true
        Column {
            id: _column
            topPadding: 10
            width: parent.width
            spacing: 35

            Item {
                width: parent.width-70
                anchors.horizontalCenter: parent.horizontalCenter
                visible: true
                height: 600
                RowLayout {
                    anchors.fill: parent
                    spacing: 35
                    InnerBackground {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        ChartView {
                            anchors.fill: parent
                            anchors.margins: -15
                            anchors.topMargin: 0
                            theme: ChartView.ChartView.ChartThemeLight
                            antialiasing: true
                            legend.visible: false
                            backgroundColor: 'transparent'
                            dropShadowEnabled: true
                            plotAreaColor: 'transparent'
                            layer.enabled: true
                            layer.effect: FastBlur {
                                radius: 32
                            }
                            AreaSeries {
                                name: "Russian"
                                //axisX: valueAxis
                                color: theme.accentColor
                                axisX: ValueAxis {
                                    visible: false
                                    gridVisible: false
                                }
                                axisY: ValueAxis {
                                    visible: false
                                    gridVisible: false
                                }
                                upperSeries: LineSeries {
                                    axisX: ValueAxis {
                                        visible: false
                                        gridVisible: false
                                    }
                                    axisY: ValueAxis {
                                        visible: false
                                        gridVisible: false
                                    }
                                    XYPoint { x: 0; y: 0 }
                                    XYPoint { x: 1.1; y: 2.1 }
                                    XYPoint { x: 1.9; y: 3.3 }
                                    XYPoint { x: 2.1; y: 2.1 }
                                    XYPoint { x: 2.9; y: 4.9 }
                                    XYPoint { x: 3.4; y: 3.0 }
                                    XYPoint { x: 4.1; y: 3.3 }
                                }
                            }
                            LineSeries {
                                 name: "LineSeries"
                                 axisX: ValueAxis {
                                     visible: false
                                     gridVisible: false
                                 }
                                 axisY: ValueAxis {
                                     visible: false
                                     gridVisible: false
                                 }

                                 XYPoint { x: 0; y: 0 }
                                 XYPoint { x: 1.1; y: 2.1 }
                                 XYPoint { x: 1.9; y: 3.3 }
                                 XYPoint { x: 2.1; y: 2.1 }
                                 XYPoint { x: 2.9; y: 4.9 }
                                 XYPoint { x: 3.4; y: 3.0 }
                                 XYPoint { x: 4.1; y: 3.3 }
                             }
                            ScatterSeries {
                                axisX: ValueAxis {
                                    visible: false
                                    gridVisible: false
                                }
                                axisY: ValueAxis {
                                    visible: false
                                    gridVisible: false
                                }
                                XYPoint { x: 0; y: 0 }
                                XYPoint { x: 1.1; y: 2.1 }
                                XYPoint { x: 1.9; y: 3.3 }
                                XYPoint { x: 2.1; y: 2.1 }
                                XYPoint { x: 2.9; y: 4.9 }
                                XYPoint { x: 3.4; y: 3.0 }
                                XYPoint { x: 4.1; y: 3.3 }
                            }

                        }
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: parent.color
                            opacity: .95
                            layer.enabled: true
                            layer.effect: FastBlur {
                                radius: 32
                            }
                        }
                        Column {
                            anchors.centerIn: parent
                            Qaterial.ColorIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: Qaterial.Icons.rocketLaunchOutline
                            }
                            spacing: 10
                            DexLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                font: theme.textType.body1
                                text: "Coming Soon."
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 350
                        Layout.fillHeight: true
                        FloatingBackground {
                            y: 35
                            height: parent.height
                            width: parent.width
                            anchors.centerIn: parent
                            ChartView {
                                width: 550
                                height: 500
                                theme: ChartView.ChartView.ChartThemeLight
                                antialiasing: true
                                legend.visible: false
                                backgroundColor: 'transparent'
                                y: -55
                                anchors.horizontalCenter: parent.horizontalCenter
                                dropShadowEnabled: true
                                PieSeries {
                                    PieSlice {
                                        label: "XRP"
                                        value: 100
                                        color: Qaterial.Colors.gray900
                                        labelColor: 'white'
                                        labelVisible: false
                                        labelFont: theme.textType.head5
                                        borderWidth: 3
                                        Behavior on explodeDistanceFactor {
                                            NumberAnimation {
                                                duration: 150
                                            }
                                        }
                                    }
                                }

                                PieSeries {
                                    id: pieSeries
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    color: theme.backgroundColor
                                    width: 285
                                    height: 285
                                    radius: 300
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        DefaultText {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text_value: currentTotal
                                                        !== "" ? currentTotal : General.formatFiat(
                                                                     "",
                                                                     API.app.portfolio_pg.balance_fiat_all,
                                                                     API.app.settings_pg.current_currency)
                                            font: theme.textType.head4
                                            color: Qt.lighter(
                                                       Style.colorWhite4,
                                                       currency_change_button.containsMouse ? Style.hoverLightMultiplier : 1.0)
                                            privacy: true
                                            DexFadebehavior on text {
                                                fadeDuration: 100
                                            }
                                            Component.onCompleted: {
                                                font.family = 'Lato'
                                            }
                                        }
                                        DefaultText {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text_value: portfolio.currentValue
                                            font: theme.textType.body1
                                            DexFadebehavior on text {
                                                fadeDuration: 100
                                            }
                                            color: Qt.lighter(Style.colorWhite4, 0.6)
                                            privacy: true
                                            Component.onCompleted: {
                                                font.family = 'Lato'
                                            }
                                        }
                                        DefaultText {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text_value: portfolio_mdl.rowCount()+" "+qsTr("Assets")
                                            font: theme.textType.body2
                                            DexFadebehavior on text {
                                                fadeDuration: 100
                                            }
                                            color: Qt.lighter(Style.colorWhite4, 0.8)
                                            privacy: true
                                            Component.onCompleted: {
                                                font.family = 'Lato'
                                            }
                                        }
                                    }
                                    DefaultMouseArea {
                                        id: currency_change_button

                                        width: parent.width - 100
                                        height: parent.height - 100
                                        anchors.centerIn: parent

                                        hoverEnabled: true
                                        onClicked: {
                                            const current_fiat = API.app.settings_pg.current_currency
                                            const available_fiats = API.app.settings_pg.get_available_currencies()
                                            const current_index = available_fiats.indexOf(
                                                                    current_fiat)
                                            const next_index = (current_index + 1) % available_fiats.length
                                            const next_fiat = available_fiats[next_index]
                                            API.app.settings_pg.current_currency = next_fiat
                                        }
                                    }
                                }
                            }
                            Item {
                                y: 380
                                width: parent.width-50
                                height: 200
                                anchors.horizontalCenter: parent.horizontalCenter
                                Column {
                                    anchors.fill: parent
                                    Repeater {
                                        model: portfolio_mdl.pie_chart_proxy_mdl

                                        RowLayout {
                                            id: rootItem
                                            property color itemColor: Style.getCoinColor(ticker)
                                            width: parent.width
                                            height: 50
                                            spacing: 20
                                            DexLabel {
                                                Layout.preferredWidth: 60
                                                text: `${ticker}`
                                                Layout.alignment: Qt.AlignVCenter
                                                Component.onCompleted: font.weight = Font.Medium
                                            }
                                            Rectangle {
                                                Layout.alignment: Qt.AlignVCenter
                                                Layout.fillWidth: true
                                                height: 8
                                                radius: 10
                                                color: theme.dexBoxBackgroundColor
                                                Rectangle {
                                                    height: parent.height
                                                    width: (parseFloat(getPercent(main_currency_balance).replace("%",""))*parent.width)/100
                                                    radius: 10
                                                    color: rootItem.itemColor
                                                }
                                            }

                                            DexLabel {
                                                text: getPercent(main_currency_balance)
                                                Component.onCompleted: font.family = 'lato'
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                        }
                                    }
                                }

                                Qaterial.DebugRectangle {
                                    anchors.fill: parent
                                    visible: false
                                }
                            }
                        }
                    }

                }
            }
            Item {
                width: parent.width
                height: 80
                visible: false
                FloatingBackground {
                    height: 80
                    width: parent.width-70
                    anchors.centerIn: parent
                    RowLayout {
                        anchors.fill: parent
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Column {
                                anchors.centerIn: parent
                                DexLabel {
                                    text: portfolio_mdl.rowCount()
                                    font: theme.textType.head5
                                    color: theme.greenColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Component.onCompleted: font.family= 'Lato'
                                }
                                DexLabel {
                                    text: qsTr("ASSETS")
                                    font: theme.textType.head6
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        VerticalLine {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 3

                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Column {
                                anchors.centerIn: parent
                                DexLabel {
                                    text: total
                                    font: theme.textType.head5
                                    color: theme.greenColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Component.onCompleted: font.family= 'Lato'
                                }
                                DexLabel {
                                    text: qsTr("TOTAL BALANCE")
                                    font: theme.textType.head6
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        VerticalLine {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 3
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Column {
                                anchors.centerIn: parent
                                DexLabel {
                                    text: total
                                    font: theme.textType.head5
                                    color: theme.greenColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Component.onCompleted: font.family= 'Lato'
                                }
                                DexLabel {
                                    text: qsTr("BALANCE 24H AGO")
                                    font: theme.textType.head6
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        VerticalLine {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 3
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Column {
                                anchors.centerIn: parent
                                DexLabel {
                                    text: "-0.0%"
                                    font: theme.textType.head5
                                    color: theme.redColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Component.onCompleted: font.family= 'Lato'
                                }
                                DexLabel {
                                    text: qsTr("SINCE 24H AGO")
                                    font: theme.textType.head6
                                    opacity: .7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }
            Item {
                width: parent.width
                height: 30
                visible: true
                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 40
                    anchors.rightMargin: 40
                    anchors.topMargin: 5
                    RowLayout {
                        anchors.fill: parent
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            DefaultSwitch {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Show only coins with balance")
                                checked: portfolio_coins.with_balance
                                onCheckedChanged: portfolio_coins.with_balance = checked
                            }
                        }
                        DexTextField {
                            id: input_coin_filter
                            implicitHeight: 45
                            function reset() {
                                if (text === "")
                                    resetCoinFilter()
                                else
                                    text = ""

                                //applyCurrentSort()
                            }

                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 250
                            height: 60

                            placeholderText: qsTr("Search")

                            onTextChanged: {
                                portfolio_coins.setFilterFixedString(text)
                            }

                            width: 120
                        }
                    }
                }
            }
            Item {
                width: parent.width
                height: 500
                visible: true
                FloatingBackground {
                    anchors.fill: parent
                    anchors.margins: 15
                    anchors.leftMargin: 40
                    anchors.rightMargin: 40
                    radius: 2
                    Item {
                        width: parent.width
                        height: 50

                        // Line
                        HorizontalLine {
                            width: parent.width
                            color: theme.barColor
                            anchors.top: parent.top
                        }

                        // Coin
                        ColumnHeader {
                            id: coin_header
                            icon_at_left: true
                            anchors.left: parent.left
                            anchors.leftMargin: 40
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Asset")
                            sort_type: sort_by_name
                        }

                        // Balance
                        ColumnHeader {
                            id: balance_header
                            icon_at_left: true
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width * 0.265
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Balance")
                            sort_type: sort_by_value
                        }

                        // Change 24h
                        ColumnHeader {
                            id: change_24h_header
                            icon_at_left: false
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width * 0.37
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Change 24h")
                            sort_type: sort_by_change
                        }

                        // 7-day Trend
                        ColumnHeader {
                            id: trend_7d_header
                            icon_at_left: false
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width * 0.2
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Trend 7d")
                            sort_type: sort_by_trend
                        }

                        // Price
                        ColumnHeader {
                            id: price_header
                            icon_at_left: false
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
                            color: theme.barColor
                            anchors.bottom: parent.bottom
                        }
                    }
                    DefaultListView {
                        id: list
                        visible: true
                        y: 50
                        width: parent.width
                        height: parent.height - 50

                        model: portfolio_coins

                        delegate: AnimatedRectangle {
                            color: Qt.lighter(
                                       mouse_area.containsMouse ? theme.hightlightColor : index % 2
                                                                  == 0 ? Qt.darker(
                                                                             theme.backgroundColor,
                                                                             0.8) : theme.backgroundColor,
                                       mouse_area.containsMouse ? Style.hoverLightMultiplier : 1.0)
                            width: list.width
                            height: 50

                            AnimatedRectangle {
                                id: main_color
                                color: Style.getCoinColor(ticker)
                                width: 10
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                            }

                            // Click area
                            DefaultMouseArea {
                                id: mouse_area
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: {
                                    if (!can_change_ticker)
                                        return

                                    if (mouse.button === Qt.RightButton)
                                        context_menu.popup()
                                    else {
                                        api_wallet_page.ticker = ticker
                                        dashboard.current_page = idx_dashboard_wallet
                                    }
                                }
                                onPressAndHold: {
                                    if (!can_change_ticker)
                                        return

                                    if (mouse.source === Qt.MouseEventNotSynthesized)
                                        context_menu.popup()
                                }
                            }

                            // Right click menu
                            CoinMenu {
                                id: context_menu
                            }

                            // Icon
                            DefaultImage {
                                id: icon
                                anchors.left: parent.left
                                anchors.leftMargin: coin_header.anchors.leftMargin

                                source: General.coinIcon(ticker)
                                width: Style.textSize2
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Name
                            DefaultText {
                                id: coin_name
                                anchors.left: icon.right
                                anchors.leftMargin: 10
                                text_value: name
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            CoinTypeTag {
                                id: tag
                                anchors.left: coin_name.right
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter

                                type: model.type

                                opacity: 0.25

                                visible: mouse_area.containsMouse
                            }

                            // Balance
                            DefaultText {
                                id: balance_value
                                anchors.left: parent.left
                                anchors.leftMargin: balance_header.anchors.leftMargin

                                text_value: General.formatCrypto(
                                                "", balance, ticker,
                                                main_currency_balance,
                                                API.app.settings_pg.current_currency)
                                color: Qt.darker(theme.foregroundColor, 0.8)
                                anchors.verticalCenter: parent.verticalCenter
                                privacy: true
                            }

                            // Change 24h
                            DefaultText {
                                id: change_24h_value
                                anchors.right: parent.right
                                anchors.rightMargin: change_24h_header.anchors.rightMargin

                                text_value: {
                                    const v = parseFloat(change_24h)
                                    return v === 0 ? '-' : General.formatPercent(v)
                                }
                                color: Style.getValueColor(change_24h)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Price
                            DefaultText {
                                id: price_value
                                anchors.right: parent.right
                                anchors.rightMargin: price_header.anchors.rightMargin

                                text_value: General.formatFiat(
                                                '', main_currency_price_for_one_unit,
                                                API.app.settings_pg.current_currency)
                                color: theme.colorThemeDarkLight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DefaultImage {
                                visible: API.app.portfolio_pg.oracle_price_supported_pairs.join(
                                             ",").indexOf(ticker) !== -1
                                source: General.coinIcon('BAND')
                                width: 12
                                height: width
                                anchors.top: price_value.top
                                anchors.left: price_value.right
                                anchors.leftMargin: 5

                                CexInfoTrigger {}
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

                                function refresh() {
                                    updateChart(chart, historical,
                                                Style.getValueColor(change_24h))
                                }

                                property bool dark_theme: Style.dark_theme
                                onDark_themeChanged: refresh()
                                onHistoricalChanged: refresh()
                                backgroundColor: "transparent"
                            }
                        }
                    }
                }

            }
            Item {
                width: 1
                height: 10
            }
        }
    }
    Item {
        width: parent.width
        height: 80
        visible: true

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                DexLabel {
                    font: theme.textType.head4
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Portfolio")
                }
            }
            Item {

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    Qaterial.ExtendedFabButton {
                        width: 180
                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Qaterial.ColorIcon {
                                source: Qaterial.Icons.plus
                            }

                            DexLabel {
                                text: qsTr("Add asset")
                            }
                        }
                        onClicked: enable_coin_modal.open()
                    }
                }

                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 200

                width: 120
            }
        }
    }





    // Top part

    // List header

    // List
}
