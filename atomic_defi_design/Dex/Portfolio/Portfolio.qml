import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtWebEngine 1.8

import QtGraphicalEffects 1.0
import QtCharts 2.3
import Qaterial 1.0 as Qaterial
import ModelHelper 0.1

import AtomicDEX.WalletChartsCategories 1.0

import "../Components"
import "../Constants" as Constants
import App 1.0

// Portfolio
Item {
    id: portfolio
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.bottomMargin: 40
    Layout.margins: 40
    property bool isUltraLarge: width > 1400
    property bool isSpline: false
    function getPercent(fiat_amount) {
        const portfolio_balance = parseFloat(
                                    Constants.API.app.portfolio_pg.balance_fiat_all)
        if (fiat_amount <= 0 || portfolio_balance <= 0)
            return "-"

        return Constants.General.formatPercent(
                    (100 * fiat_amount / portfolio_balance).toFixed(2), false)
    }

    property string total: Constants.General.formatFiat(
                               "", Constants.API.app.portfolio_pg.balance_fiat_all,
                               Constants.API.app.settings_pg.current_currency)
    readonly property int sort_by_name: 0
    readonly property int sort_by_value: 1
    readonly property int sort_by_change: 3
    readonly property int sort_by_trend: 4
    readonly property int sort_by_price: 5
    property string currentValue: ""
    property string currentTotal: ""
    property var portfolio_helper: portfolio_mdl.pie_chart_proxy_mdl.ModelHelper

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

    onTotalChanged: {
        pie.refresh()
        pie.pieTimer2.restart()
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

    Flickable {
        id: flick
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
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                visible: true
                height: portfolio.isUltraLarge ? 600 : 350
                RowLayout {
                    anchors.fill: parent
                    anchors.rightMargin: 40
                    anchors.leftMargin: 40
                    spacing: 35
                    AmountChart {
                        id: willyBG
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: false
                    }

                    AssetPieChart {
                        id: pie
                        Layout.fillWidth: true
                        Layout.preferredHeight: portfolio.isUltraLarge ? 600 : 350
                        Layout.alignment: Qt.AlignTop
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

                        SearchField
                        {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 206
                            Layout.preferredHeight: 42

                            textField.placeholderText: qsTr("Search asset")

                            textField.font.pixelSize: Constants.Style.textSizeSmall3
                            textField.onTextChanged: portfolio_coins.setFilterFixedString(textField.text)
                            Component.onDestruction: portfolio_coins.setFilterFixedString("")
                        }
                        
                        Item {
                            Layout.fillWidth: true
                        }
                        
                        DexCheckBox
                        {
                            Layout.alignment: Qt.AlignVCenter
                            text: qsTr("Show only coins with balance") + " <b>%1</b>".arg(qsTr("(%1/%2)").arg(coinsList.count).arg(portfolio_mdl.length))
                            checked: portfolio_coins.with_balance
                            onCheckedChanged: portfolio_coins.with_balance = checked

                            Component.onDestruction: portfolio_coins.with_balance = false
                        }
                    }
                }
            }

            AssetsList
            {
                id: coinsList
                width: parent.parent.width - 80
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                width: 1
                height: 10
            }
        }
    }
    Item
    {
        width: parent.width
        height: 80
        visible: true

        RowLayout
        {
            anchors.fill: parent
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            anchors.topMargin: 30
            
            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                DexLabel
                {
                    font: DexTypo.head6
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Portfolio")
                }
            }

            Item
            {
                Row
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    
                    DexGradientAppButton
                    {
                        height: 61.5
                        iconSource: Qaterial.Icons.plus
                        radius: 18
                        leftPadding: 5
                        rightPadding: 5
                        padding: 16
                        text: qsTr("Add asset")
                        onClicked: enable_coin_modal.open()
                    }
                }

                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 200

                width: 120
            }
        }
    }
}
