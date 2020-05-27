import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtCharts 2.3
import "../Components"
import "../Constants"

// List
ChartView {
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
            labelsColor: series.axisX.labelsColor
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
        axisY: ValueAxis {
            visible: false
            titleVisible: series.axisY.titleVisible
            lineVisible: series.axisY.lineVisible
            labelsFont: series.axisY.labelsFont
            gridLineColor: series.axisY.gridLineColor
            labelsColor: series.axisY.labelsColor
        }
    }

    AreaSeries {
        id: series_area2
        color: Style.colorTheme10

        borderWidth: series_area.borderWidth
        opacity: series_area.opacity

        axisX: series2.axisX
        axisY: series2.axisY
        upperSeries: series2
    }

    function updateChart() {
        const coin = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
        if(coin === undefined) return

        const historical = coin.historical
        if(historical === undefined) return

        let i
        if(historical.length > 0) {
            for(i = 0; i < historical.length; ++i) {
                series.append(General.timestampToDouble(historical[i].timestamp), historical[i].price)
                series2.append(General.timestampToDouble(historical[i].timestamp), historical[i].volume_24h)
            }

            series.axisX.tickCount = historical.length
            series2.axisX.tickCount = historical.length
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
