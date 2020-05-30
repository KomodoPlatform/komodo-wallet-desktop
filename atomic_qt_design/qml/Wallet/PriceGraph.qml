import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtCharts 2.3
import "../Components"
import "../Constants"

// List
ChartView {
    // Other, back
    LineSeries {
        id: series2
        color: Style.colorTheme10

        style: series.style
        width: series.width

        pointsVisible: true

        axisX: DateTimeAxis {
            visible: false
            titleVisible: series.axisX.titleVisible
            lineVisible: series.axisX.lineVisible
            labelsFont: series.axisX.labelsFont
            gridLineColor: series.axisX.gridLineColor
            labelsColor: series.axisX.labelsColor
            format: "MMM d"
        }
        axisYRight: ValueAxis {
            visible: true
            titleVisible: series.axisY.titleVisible
            lineVisible: series.axisY.lineVisible
            labelsFont: series.axisY.labelsFont
            gridLineColor: series.axisY.gridLineColor
            labelsColor: series2.color
        }
    }

    AreaSeries {
        id: series_area2
        color: Style.colorTheme10

        borderWidth: series_area.borderWidth
        opacity: series_area.opacity

        axisX: series2.axisX
        axisYRight: series2.axisYRight
        upperSeries: series2
    }

    // Price, front
    LineSeries {
        id: series
        color: Style.colorTheme1

        style: Qt.SolidLine
        width: 2

        pointsVisible: true

        axisX: DateTimeAxis {
            titleVisible: false
            lineVisible: false
            labelsFont: Style.font
            gridLineColor: Style.colorThemeDark2
            labelsColor: gridLineColor
            format: "MMM d"
        }
        axisY: ValueAxis {
            titleVisible: series.axisX.titleVisible
            lineVisible: series.axisX.lineVisible
            labelsFont: series.axisX.labelsFont
            gridLineColor: series.axisX.gridLineColor
            labelsColor: series.color
        }
    }

    AreaSeries {
        id: series_area
        color: Style.colorTheme1

        borderWidth: 0
        opacity: 0.05

        axisX: series.axisX
        axisY: series.axisY
        upperSeries: series
    }

    function updateChart() {
        series.clear()
        series2.clear()

        const coin = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
        if(coin === undefined) return

        const historical = coin.historical
        if(historical === undefined) return

        if(historical.length > 0) {
            let min_price = Infinity
            let max_price = -Infinity
            let min_other = Infinity
            let max_other = -Infinity

            for(let i = 0; i < historical.length; ++i) {
                const price = historical[i].price
                const other = historical[i].volume_24h

                series.append(General.timestampToDouble(historical[i].timestamp), price)
                series2.append(General.timestampToDouble(historical[i].timestamp), other)

                min_price = Math.min(min_price, price)
                max_price = Math.max(max_price, price)
                min_other = Math.min(min_other, other)
                max_other = Math.max(max_other, other)
            }

            // Date
            series.axisX.min = historical[0].timestamp
            series.axisX.max = historical[historical.length-1].timestamp
            series.axisX.tickCount = historical.length

            series2.axisX.min = series.axisX.min
            series2.axisX.max = series.axisX.max
            series2.axisX.tickCount = series.axisX.tickCount

            const y_margin = 0.05
            // Price
            series.axisY.min = min_price * (1 - y_margin)
            series.axisY.max = max_price * (1 + y_margin)

            // Other
            series2.axisYRight.min = min_other * (1 - y_margin)
            series2.axisYRight.max = max_other * (1 + y_margin)
        }
    }

    property string ticker: API.get().current_coin_info.ticker
    onTickerChanged: {
        updateChart()
    }

    Connections {
        target: dashboard

        onPortfolio_coinsChanged: {
            updateChart()
        }
    }

    id: chart
    width: parent.width
    height: parent.height
    antialiasing: true

    legend.visible: false

    backgroundColor: "transparent"
}





/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
