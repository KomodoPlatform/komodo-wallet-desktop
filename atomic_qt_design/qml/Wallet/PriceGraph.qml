import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import "../Components"
import "../Constants"

// List
Rectangle {
    function reset() {

    }
    function updateChart() {
        const coin = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
        if(coin === undefined) return

        chart.removeAllSeries()

        const historical = coin.historical
        if(historical === undefined) return

        let i
        if(historical.length > 0) {
            // Fill chart
            let series = chart.createSeries(ChartView.SeriesTypeLine, "Price", chart.axes[0], chart.axes[1]);

            series.style = Qt.SolidLine
            series.color = Style.colorTheme1

            let min = 999999999
            let max = -999999999
            for(i = 0; i < historical.length; ++i) {
                let price = historical[i].price
                series.append(i, historical[i].price)
                min = Math.min(min, price)
                max = Math.max(max, price)
            }


            chart.axes[1].min = min * 0.99
            chart.axes[1].max = max * 1.01
        }

        chart.axes[0].min = 0
        chart.axes[0].max = historical.length - 1
    }

    radius: Style.rectangleCornerRadius

    color: Style.colorTheme8

    ChartView {
        id: chart
        width: parent.width
        height: parent.height
        antialiasing: true

        legend.visible: false

        backgroundColor: "transparent"
    }
}






/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
