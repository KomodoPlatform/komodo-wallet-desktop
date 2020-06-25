import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtCharts 2.3
import "../../Components"
import "../../Constants"

// List
ChartView {
    id: chart
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

        increasingColor: Style.colorGreen
        decreasingColor: Style.colorRed
        bodyOutlineVisible: false

        //onHovered: updateValueText(state, point.y, axisY.labelsColor, 2)

        axisX: DateTimeAxis {
            titleVisible: false
            lineVisible: true
            labelsFont.family: Style.font
            labelsFont.pixelSize: Style.textSizeVerySmall8
            gridLineColor: Style.colorThemeDark2
            labelsColor: Style.colorThemeDark3
            color: gridLineColor
            format: "MMM d"
        }
        axisYRight: ValueAxis {
            titleVisible: series.axisX.titleVisible
            lineVisible: series.axisX.lineVisible
            labelsFont: series.axisX.labelsFont
            gridLineColor: series.axisX.gridLineColor
            labelsColor: series.axisX.labelsColor
            color: series.axisX.color
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


    function updateChart() {
        series.clear()
        //series2.clear()

        const historical = API.get().get_price_chart
        if(historical === undefined) return

        if(historical.length > 0) {
            let min_price = Infinity
            let max_price = -Infinity
            let min_other = Infinity
            let max_other = -Infinity

            for(let i = 0; i < historical.length; ++i) {
                series.append(historical[i].open, historical[i].high, historical[i].low, historical[i].close, historical[i].timestamp * 1000)
                //series2.append(General.timestampToDate(historical[i].timestamp), other)
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
            const y_margin = 0.02

            // Price
            series.axisYRight.min = min_price * (1 - y_margin)
            series.axisYRight.max = max_price * (1 + y_margin)
/*
            // Other
            series2.axisYRight.min = min_other * (1 - y_margin)
            series2.axisYRight.max = max_other * (1 + y_margin)
*/
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
                color: series.axisYRight.labelsColor
            }
        }
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
        }

        property double valueX
        property double valueY
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
