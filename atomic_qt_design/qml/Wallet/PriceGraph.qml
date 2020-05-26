import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtCharts 2.3
import "../Components"
import "../Constants"

// List
ChartView {
    axes: [
        DateTimeAxis {
            id: date_axis
            titleVisible: false
            lineVisible: false
            labelsFont: Style.font
            gridLineColor: Style.colorThemeDark2
            labelsColor: gridLineColor
            format: "MMM d"
        },

        ValueAxis {
            id: value_axis
            titleVisible: false
            lineVisible: false
            labelsFont: Style.font
            gridLineColor: date_axis.gridLineColor
            labelsColor: gridLineColor
        }
    ]

    function updateChart() {
        const coin = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
        if(coin === undefined) return

        chart.removeAllSeries()

        const historical = coin.historical
        if(historical === undefined) return

        let i
        if(historical.length > 0) {
            console.log(JSON.stringify(historical))
            // Fill chart
            chart.titleColor = Style.colorTheme1
            let series_area = chart.createSeries(ChartView.SeriesTypeArea, "price_area", date_axis, value_axis);
            let series = chart.createSeries(ChartView.SeriesTypeLine, "price", date_axis, value_axis);

            series.style = Qt.SolidLine
            series.color = Style.colorTheme1
            series.width = 2
            series.pointsVisible = true

            series_area.borderWidth = 0
            series_area.color = series.color
            series_area.opacity = 0.05

            let min = 999999999
            let max = -999999999
            for(i = 0; i < historical.length; ++i) {
                let price = historical[i].price
                series.append(General.timestampToDouble(historical[i].timestamp), historical[i].price)
                min = Math.min(min, price)
                max = Math.max(max, price)
            }

            series_area.upperSeries = series

            chart.axisY().min = min * 0.99
            chart.axisY().max = max * 1.01

            chart.axisX().min = historical[0].timestamp
            chart.axisX().max = historical[historical.length - 1].timestamp
            chart.axisX().tickCount = historical.length
        }
    }

    property string ticker: API.get().current_coin_info.ticker
    onTickerChanged: {
        updateChart()
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
