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

    LineSeries {
        id: series
        style: Qt.SolidLine
        color: Style.colorTheme1
        width: 2
        pointsVisible: true
        axisX: date_axis
        axisY: value_axis
    }

    AreaSeries {
        id: series_area
        borderWidth: 0
        color: Style.colorTheme1
        opacity: 0.05

        axisX: date_axis
        axisY: value_axis
        upperSeries: series
    }

    function updateChart() {
        const coin = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
        if(coin === undefined) return

        const historical = coin.historical
        if(historical === undefined) return

        let i
        if(historical.length > 0) {
            console.log(JSON.stringify(historical))

            for(i = 0; i < historical.length; ++i) {
                series.append(General.timestampToDouble(historical[i].timestamp), historical[i].price)
            }

            date_axis.tickCount = historical.length
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
