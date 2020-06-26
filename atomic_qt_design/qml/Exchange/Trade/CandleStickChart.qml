import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtCharts 2.3
import "../../Components"
import "../../Constants"

// List
ChartView {
    id: chart
    readonly property double y_margin: 0.02

    margins.top: 0
    margins.left: 0
    margins.bottom: 0
    margins.right: 0


    AreaSeries {
        id: series_area

        property double global_max: -Infinity

        color: Style.colorBlue

        borderWidth: 0
        opacity: 0.3

        axisX: series.axisX
        axisY: ValueAxis {
            id: value_axis_area
            visible: false
            onRangeChanged: {
                // This will be always same, small size at bottom
                value_axis_area.min = 0
                value_axis_area.max = series_area.global_max * 1/0.5
            }
        }
        upperSeries:  LineSeries { visible: false }
    }

    // Moving Average 1
    LineSeries {
        id: series_ma1

        readonly property int num: 20

        color: Style.colorChartMA1

        width: 1

        pointsVisible: false

        axisX: series.axisX
        axisYRight: series.axisYRight
    }

    // Moving Average 2
    LineSeries {
        id: series_ma2

        readonly property int num: 50

        color: Style.colorChartMA2

        width: series_ma1.width

        pointsVisible: false

        axisX: series.axisX
        axisYRight: series.axisYRight
    }

    /*AreaSeries {
        id: series_area2
        color: Style.colorTheme10

        onHovered: updateValueText(state, point.y, axisYRight.labelsColor, 0)

        borderWidth: series_area.borderWidth
        opacity: series_area.opacity

        axisX: series2.axisX
        axisYRight: series2.axisYRight
        upperSeries: series2
    }

    // Other, back
    LineSeries {
        id: series2
        color: Style.colorTheme10

        style: series.style
        width: series.width

        pointsVisible: false

        onHovered: updateValueText(state, point.y, axisYRight.labelsColor, 0)

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
        id: series_area
        color: Style.colorTheme1
        onHovered: updateValueText(state, point.y, axisY.labelsColor, 2)

        borderWidth: 0
        opacity: 0.15

        axisX: series.axisX
        axisY: series.axisY
        upperSeries: series
    }*/



    // Price, front
    CandlestickSeries {
        id: series

        property double global_max: -Infinity

        increasingColor: Style.colorGreen
        decreasingColor: Style.colorRed
        bodyOutlineVisible: false

        //onHovered: updateValueText(state, point.y, axisY.labelsColor, 2)

        axisX: DateTimeAxis {
            titleVisible: false
            lineVisible: true
            labelsFont.family: Style.font
            labelsFont.pixelSize: Style.textSizeVerySmall8
            gridLineColor: Style.colorChartGrid
            labelsColor: Style.colorChartText
            color: Style.colorChartLegendLine
            format: "MMM d"
        }
        axisYRight: ValueAxis {
            id: value_axis
            titleVisible: series.axisX.titleVisible
            lineVisible: series.axisX.lineVisible
            labelsFont: series.axisX.labelsFont
            gridLineColor: series.axisX.gridLineColor
            labelsColor: series.axisX.labelsColor
            color: series.axisX.color

            onRangeChanged: {
                if(min < 0) value_axis.min = 0

                const max_val = value_axis.global_max * (1 + y_margin)
                if(max > max_val) value_axis.max = max_val
            }
        }
    }

    function updateValueText(state, value, color, precision) {
        value_text.visible = state
        value_text.text = General.formatDouble(value, precision)
        value_text.color = color
    }

    DefaultText {
        id: value_text
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 50
        anchors.leftMargin: anchors.topMargin * 2
        font.pixelSize: Style.textSizeSmall3
    }

    function getHistorical() {
        return API.get().get_price_chart
    }

    function fixTimestamp(t) {
        return t * 1000
    }

    function updateChart() {
        series.clear()
        series_area.upperSeries.clear()

        series.global_max = -Infinity
        series_area.global_max = -Infinity

        const historical = getHistorical()
        if(historical === undefined) return

        if(historical.length > 0) {
            let min_price = Infinity
            let max_price = -Infinity
            let min_other = Infinity
            let max_other = -Infinity

            for(let i = 0; i < historical.length; ++i) {
                series.append(historical[i].open, historical[i].high, historical[i].low, historical[i].close, fixTimestamp(historical[i].timestamp))
                series_area.upperSeries.append(General.timestampToDate(historical[i].timestamp), historical[i].volume)

                if(series_area.global_max < historical[i].volume) series_area.global_max = historical[i].volume
            }

            const first_idx = historical.length * 0.9
            const last_idx = historical.length - 1

            // Set min and max values
            for(let j = first_idx; j <= last_idx; ++j) {
                const price = historical[j].close
                const other = historical[j].volume

                min_price = Math.min(min_price, price)
                max_price = Math.max(max_price, price)
                min_other = Math.min(min_other, other)
                max_other = Math.max(max_other, other)
            }


            // Date
            series.axisX.min = General.timestampToDate(historical[first_idx].timestamp)
            series.axisX.max = General.timestampToDate(historical[last_idx].timestamp)
            series.axisX.tickCount = 10//historical.length
/*
            series2.axisX.min = series.axisX.min
            series2.axisX.max = series.axisX.max
            series2.axisX.tickCount = series.axisX.tickCount
*/

            // Price
            series.axisYRight.min = min_price * (1 - y_margin)
            series.axisYRight.max = max_price * (1 + y_margin)

            // Other
            series_area.axisY.min = min_other * (1 - y_margin)
            series_area.axisY.max = max_other * (1 + y_margin)


            computeMovingAverage()
        }
    }

    property string ticker: API.get().current_coin_info.ticker
    onTickerChanged: {
        updateChart()
    }

    Connections {
        target: dashboard

        function onPortfolio_coinsChanged() {
            updateChart()
        }
    }

    width: parent.width
    height: parent.height
    antialiasing: true

    legend.visible: false

    backgroundColor: "transparent"


    Canvas {
        readonly property color color: Style.colorGreen
        anchors.left: parent.left
        width: parent.width
        height: 1
        y: mouse_area.mouseY
        onPaint: {
            var ctx = getContext("2d");

            ctx.setLineDash([1, 1]);
            ctx.lineWidth = 1.5;
            ctx.strokeStyle = color

            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.stroke()
        }

        Rectangle {
            color: parent.color
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            width: 30
            height: value_y_text.height
            DefaultText {
                id: value_y_text
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: General.formatDouble(mouse_area.valueY, 0)
                font.pixelSize: series.axisYRight.labelsFont.pixelSize
                color: Style.colorChartLineText
            }
        }
    }

    // Cursor values
    DefaultText {
        id: cursor_values
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.leftMargin: 75
        color: series.axisX.labelsColor
        font.pixelSize: Style.textSizeSmall
        property string highlightColor: mouse_area.realData && mouse_area.realData.close >= mouse_area.realData.open ? Style.colorGreen : Style.colorRed
        text: mouse_area.realData ? (
                `O:<font color="${highlightColor}">${mouse_area.realData.open}</font> &nbsp;&nbsp; ` +
                `H:<font color="${highlightColor}">${mouse_area.realData.high}</font> &nbsp;&nbsp; ` +
                `L:<font color="${highlightColor}">${mouse_area.realData.low}</font> &nbsp;&nbsp; ` +
                `C:<font color="${highlightColor}">${mouse_area.realData.close}</font> &nbsp;&nbsp; ` +
                `Vol:<font color="${highlightColor}">${mouse_area.realData.volume.toFixed(0)}K</font>`
                                        ) : ``

    }

    // MA texts
    DefaultText {
        anchors.left: cursor_values.left
        anchors.top: cursor_values.bottom
        anchors.topMargin: 6
        font.pixelSize: cursor_values.font.pixelSize
        text: `<font color="${series_ma1.color}">MA ${series_ma1.num}</font> &nbsp;&nbsp; <font color="${series_ma2.color}">MA ${series_ma2.num}</font>`
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent

        // Zoom in/out with wheel
        readonly property double scroll_speed: 0.1
        onWheel: {
            if (wheel.angleDelta.y !== 0)
                chart.zoom(1 + (-wheel.angleDelta.y/360) * scroll_speed)
        }

        // Drag scroll
        hoverEnabled: true
        property double prev_x
        property double prev_y
        onPositionChanged: {
            if(mouse.buttons > 0) {
                const diff_x = mouse.x - prev_x
                const diff_y = mouse.y - prev_y

                if(diff_x > 0) chart.scrollLeft(diff_x)
                else if(diff_x < 0) chart.scrollRight(-diff_x)
                if(diff_y > 0) chart.scrollUp(diff_y)
                else if(diff_y < 0) chart.scrollDown(-diff_y)
            }

            prev_x = mouse.x
            prev_y = mouse.y

            // Map mouse position to value
            const cp = chart.mapToValue(Qt.point(mouse.x, mouse.y), series)
            valueX = cp.x
            valueY = cp.y

            // Find closest real data
            realData = findRealData(valueX)
        }

        property double valueX
        property double valueY
        property var realData

        function findRealData(timestamp) {
            const historical = getHistorical()
            const count = historical.length

            let closest_idx
            let closest_dist = Infinity

            for(let i = 1; i < count; ++i) {
                const dist = Math.abs(timestamp - fixTimestamp(historical[i].timestamp))
                if(dist < closest_dist) {
                    closest_dist = dist
                    closest_idx = i
                }
            }

            return historical[closest_idx]
        }
    }


    function addMovingAverage(historical, serie, sums, i) {
        if(i >= serie.num) serie.append(fixTimestamp(historical[i].timestamp), (sums[i] - sums[i - serie.num]) / serie.num)
    }

    function computeMovingAverage() {
        series_ma1.clear()
        series_ma2.clear()

        const historical = getHistorical()
        const count = historical.length

        let result = []
        let sums = []
        for(let i = 0; i < count; ++i) {
            // Accumulate
            if(i === 0) sums.push(historical[i].open)
            else sums.push(historical[i].open + sums[i - 1])

            // Calculate MA
            addMovingAverage(historical, series_ma1, sums, i)
            addMovingAverage(historical, series_ma2, sums, i)
        }
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
