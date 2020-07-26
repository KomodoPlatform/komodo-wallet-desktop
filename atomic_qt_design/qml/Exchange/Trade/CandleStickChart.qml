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
    readonly property bool has_data: series.count > 0

    margins.top: 0
    margins.left: 0
    margins.bottom: 0
    margins.right: 0

    Component.onCompleted: {
        API.get().candlestick_charts_mdl.modelReset.connect(chartUpdated)
        API.get().candlestick_charts_mdl.chartFullyModelReset.connect(chartFullyReset)
    }

    property double first_value_timestamp
    property double last_value_timestamp
    property double global_min_value
    property double global_max_value

    function chartFullyReset() {
        updater.locked_min_max_value = true
        chartUpdated()
        update_last_value_y_timer.restart()
    }

    function chartUpdated() {
        const mapper = cs_mapper
        const model = mapper.model

        // Update last value line
        const last_idx = series.count - 1
        const last_open = model.data(model.index(last_idx, mapper.openColumn), 0)
        const last_close = model.data(model.index(last_idx, mapper.closeColumn), 0)
        series.last_value = last_close
        series.last_value_green = last_close >= last_open
        series.updateLastValueY()

        // Get timestamp caps
        first_value_timestamp = model.data(model.index(0, mapper.timestampColumn), 0)
        last_value_timestamp = model.data(model.index(last_idx, mapper.timestampColumn), 0)
        global_min_value = model.global_min_value
        global_max_value = model.global_max_value

        // Update other stuff
        updater.updateChart()
    }

    AreaSeries {
        id: series_area

        property double global_max: 0

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
        upperSeries: LineSeries { visible: false }
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

    // Price, front
    CandlestickSeries {
        id: series

        HCandlestickModelMapper {
            id: cs_mapper
            model: API.get().candlestick_charts_mdl

            timestampColumn: 0
            openColumn: 1
            highColumn: 2
            lowColumn: 3
            closeColumn: 4

            firstSetRow: 0
            lastSetRow: model.series_size
        }

        property double global_max: 0
        property double last_value: 0
        property bool last_value_green: true

        function updateLastValueY() {
            const area = plotArea
            horizontal_line.y = Math.max(Math.min(chart.mapToPosition(Qt.point(0, series.last_value), series).y, area.y + area.height), area.y)
        }

        Timer {
            id: update_last_value_y_timer
            interval: 50
            repeat: false
            running: false
            onTriggered: series.updateLastValueY()
        }

        increasingColor: Style.colorGreen
        decreasingColor: Style.colorRed
        bodyOutlineVisible: false

        axisX: DateTimeAxis {
            id: date_time_axis
            min: cs_mapper.model.series_from
            max: cs_mapper.model.series_to

            tickCount: 10
            titleVisible: false
            lineVisible: true
            labelsFont.family: Style.font_family
            labelsFont.weight: Font.Bold
            gridLineColor: Style.colorChartGrid
            labelsColor: Style.colorChartText
            color: Style.colorChartLegendLine
            format: "MMM d"
        }
        axisYRight: ValueAxis {
            id: value_axis

            min: cs_mapper.model.min_value
            max: cs_mapper.model.max_value

            titleVisible: series.axisX.titleVisible
            lineVisible: series.axisX.lineVisible
            labelsFont: series.axisX.labelsFont
            gridLineColor: series.axisX.gridLineColor
            labelsColor: series.axisX.labelsColor
            color: series.axisX.color

            labelFormat: "%llf"

            onRangeChanged: {
//                if(min < 0) value_axis.min = 0

//                const max_val = value_axis.global_max * (1 + y_margin)
//                if(max > max_val) value_axis.max = max_val
            }
        }
    }

    function fixTimestamp(t) {
        return t * 1000
    }

    function getChartSeconds() {
        const idx = combo_time.currentIndex
        const timescale = General.chart_times[idx]
        return General.time_seconds[timescale]
    }

    function getHistorical() {
        const seconds_str = "" + getChartSeconds()
        const data = API.get().get_ohlc_data(seconds_str)
        return data
    }

    function initChart() {
        series.clear()
        series_area.upperSeries.clear()
        series_ma1.clear()
        series_ma2.clear()

        series.global_max = 0
        series.last_value = 0
        series_area.global_max = 0

        const historical = getHistorical()
        console.log("Updating the chart...")
        const count = historical.length
        if(count === 0) return

        // Prepare the chart
        let min_price = Infinity
        let max_price = 0
        let min_other = Infinity
        let max_other = 0

        for(let i = 0; i < count; ++i) {
            series.append(historical[i].open, historical[i].high, historical[i].low, historical[i].close, fixTimestamp(historical[i].timestamp))
            series_area.upperSeries.append(General.timestampToDate(historical[i].timestamp), historical[i].volume)

            if(series_area.global_max < historical[i].volume) series_area.global_max = historical[i].volume
        }

        const first_idx = Math.floor(count * 0.9)
        const last_idx = count - 1

        const last_elem = historical[last_idx]
        series.last_value = last_elem.close
        series.last_value_green = last_elem.close >= last_elem.open

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
        series.axisX.max = General.timestampToDate(last_elem.timestamp)
        series.axisX.tickCount = 10//count
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

        updater.updateChart()
    }

    width: parent.width
    height: parent.height
    antialiasing: true

    legend.visible: false

    backgroundColor: "transparent"

    // Horizontal line
    Canvas {
        id: horizontal_line
        readonly property color color: series.last_value_green ? Style.colorGreen : Style.colorRed
        onColorChanged: requestPaint()
        anchors.left: parent.left
        width: parent.width
        height: 1

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

            width: Math.max(value_y_text.width, 30)
            height: value_y_text.height
            DefaultText {
                id: value_y_text
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text_value: General.formatDouble(series.last_value, General.recommendedPrecision)
                font.pixelSize: series.axisYRight.labelsFont.pixelSize
                color: Style.colorChartLineText
            }
        }
    }

    // Cursor Horizontal line
    Canvas {
        id: cursor_horizontal_line
        readonly property color color: Style.colorBlue
        anchors.left: parent.left
        width: parent.width
        height: 1

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

            width: Math.max(cursor_y_text.width, 30)
            height: cursor_y_text.height
            DefaultText {
                id: cursor_y_text
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: series.axisYRight.labelsFont.pixelSize
            }
        }
    }

    // Cursor Vertical line
    Canvas {
        id: cursor_vertical_line
        property double x_position: 0
        readonly property color color: Style.colorBlue

        anchors.top: parent.top
        width: 1
        height: parent.height

        onPaint: {
            var ctx = getContext("2d");

            ctx.setLineDash([1, 1]);
            ctx.lineWidth = 1.5;
            ctx.strokeStyle = color

            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, height)
            ctx.stroke()
        }

        Rectangle {
            color: parent.color
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            width: cursor_x_text.width
            height: cursor_x_text.height

            DefaultText {
                id: cursor_x_text
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: series.axisYRight.labelsFont.pixelSize
            }
        }
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent

        onWheel: updater.delta_wheel_y += wheel.angleDelta.y

        // Drag scroll
        hoverEnabled: true
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


    // Time selection
    DefaultComboBox {
        id: combo_time
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.leftMargin: 35
        width: 75
        height: 30
        flat: true
        font.pixelSize: Style.textSizeSmall3

        currentIndex: 5 // 1h
        model: General.chart_times

        property bool initialized: false
        onCurrentTextChanged: {
            if(initialized) cs_mapper.model.current_range = "" + getChartSeconds()
            else initialized = true
        }
    }

    // Cursor values
    DefaultText {
        id: cursor_values
        anchors.left: combo_time.right
        anchors.top: combo_time.top
        anchors.leftMargin: 10
        color: series.axisX.labelsColor
        font.pixelSize: Style.textSizeSmall
    }

    // MA texts
    DefaultText {
        anchors.left: cursor_values.left
        anchors.bottom: combo_time.bottom
        font.pixelSize: cursor_values.font.pixelSize
        text_value: `<font color="${series_ma1.color}">MA ${series_ma1.num}</font> &nbsp;&nbsp; <font color="${series_ma2.color}">MA ${series_ma2.num}</font>`
    }



    // Canvas updater
    Timer {
        id: update_block_timer
        running: false
        repeat: false
        interval: 1
        onTriggered: updater.can_update = true
    }
    Timer {
        id: updater
        property bool can_update: true

        readonly property double scroll_speed_x: 0.0001
        readonly property double scroll_speed_y: 0.05
        property double delta_wheel_y: 0
        property double click_started_inside_area
        property double prev_mouse_pressed
        property double prev_mouse_x
        property double prev_mouse_y

        interval: 1
        running: mouse_area.containsMouse
        repeat: true
        onTriggered: updateChart()

        property bool locked_min_max_value: true
        readonly property double visible_min_value: cs_mapper.model.visible_min_value
        readonly property double visible_max_value: cs_mapper.model.visible_max_value

        onVisible_min_valueChanged: {
            if(locked_min_max_value) {
                cs_mapper.model.min_value = visible_min_value
            }
        }

        onVisible_max_valueChanged: {
            if(locked_min_max_value) {
                cs_mapper.model.max_value = visible_max_value
            }
        }

        function capDateStart(timestamp, current_distance) {
            return Math.max(timestamp, first_value_timestamp - current_distance*0.9)
        }

        function capDateEnd(timestamp, current_distance) {
            return Math.min(timestamp, last_value_timestamp + current_distance*0.9)
        }

        function capPriceMin(price) {
            return Math.max(price, global_min_value)
        }
        function capPriceMax(price) {
            return Math.min(price, global_max_value)
        }

        function getMinTimeDifference() {
            return 20 * getChartSeconds() * 1000
        }

        function getMinValueDifference() {
            return series.last_value * 0.05
        }

        function scrollHorizontal(pixels) {
            const model = cs_mapper.model
            const min = model.series_from.getTime()
            const max = model.series_to.getTime()

            const diff = max - min
            const scale = pixels / chart.plotArea.width
            const amount = diff * scale

            // Cap without zooming, more complex
            let new_max = capDateEnd(max - amount, diff)
            const new_min = capDateStart(new_max - diff, diff)
            new_max = capDateEnd(new_min + diff, diff)

            if(new_max - new_min < getMinTimeDifference()) return
            model.series_from = new Date(new_min)
            model.series_to = new Date(new_max)
        }

        function scrollVertical(pixels) {
            if(locked_min_max_value) return

            const model = cs_mapper.model
            const min = model.min_value
            const max = model.max_value
            const scale = pixels / chart.plotArea.height
            const amount = (max - min) * scale

            const new_min = capPriceMin(model.min_value + amount)
            const new_max = capPriceMax(model.max_value + amount)
            if(new_max - new_min < getMinValueDifference()) return
            model.min_value = new_min
            model.max_value = new_max
        }

        function zoomHorizontal(factor) {
            const model = cs_mapper.model
            const min = model.series_from.getTime()
            const max = model.series_to.getTime()

            const diff = max - min

            const new_min = capDateStart(min * (1 - factor), diff)
            const new_max = capDateEnd(max * (1 + 0.2*factor), diff)
            if(new_max - new_min < getMinTimeDifference()) return
            model.series_from = new Date(new_min)
            model.series_to = new Date(new_max)
        }

        function zoomVertical(factor) {
            locked_min_max_value = false

            const model = cs_mapper.model

            const new_min = capPriceMin(model.min_value * (1 - factor))
            const new_max = capPriceMax(model.max_value * (1 + factor))
            if(new_max - new_min < getMinValueDifference()) return
            model.min_value = new_min
            model.max_value = new_max
        }

        function updateChart() {
            if(!can_update) return
            can_update = false

            // Update
            const mouse_x = mouse_area.mouseX
            const mouse_y = mouse_area.mouseY
            const diff_x = mouse_x - prev_mouse_x
            const diff_y = mouse_y - prev_mouse_y
            prev_mouse_x = mouse_x
            prev_mouse_y = mouse_y

            const area = chart.plotArea
            const inside_plot_area = mouse_x < area.x + area.width

            const curr_mouse_pressed = mouse_area.containsPress
            const clicked = !prev_mouse_pressed && curr_mouse_pressed
            prev_mouse_pressed = curr_mouse_pressed

            if(clicked) {
                click_started_inside_area = inside_plot_area
            }

            // Update drag
            if(curr_mouse_pressed) {
                if(click_started_inside_area && diff_x !== 0) {
                    scrollHorizontal(diff_x)
                }

                if(diff_y !== 0) {
                    if(click_started_inside_area) {
                        scrollVertical(diff_y)
                    }
                    else {
                        zoomVertical((diff_y/area.height) * scroll_speed_y)
                    }

                    series.updateLastValueY()
                }
            }

            // Update zoom
            const zoomed = delta_wheel_y !== 0
            if (zoomed) {
                if(inside_plot_area) zoomHorizontal((-delta_wheel_y/360) * scroll_speed_x)
                else zoomVertical((-delta_wheel_y/360) * scroll_speed_y)

                delta_wheel_y = 0
            }

            // Update cursor line
            if(zoomed || diff_x !== 0 || diff_y !== 0) {
                // Map mouse position to value
                const cp = chart.mapToValue(Qt.point(mouse_x, mouse_y), series)

                // Find closest real data
                const realData = API.get().find_closest_ohlc_data(getChartSeconds(), cp.x / 1000)
                const realDataFound = realData.timestamp
                if(realDataFound) {
                    cursor_vertical_line.x = chart.mapToPosition(Qt.point(realData.timestamp*1000, 0), series).x
                }

                // Texts
                cursor_x_text.text_value = realDataFound ? General.timestampToDate(realData.timestamp).toString() : ""
                cursor_y_text.text_value = General.formatDouble(cp.y, General.recommendedPrecision)

                const highlightColor = realDataFound && realData.close >= realData.open ? Style.colorGreen : Style.colorRed
                cursor_values.text_value = realDataFound ? (
                        `O:<font color="${highlightColor}">${realData.open}</font> &nbsp;&nbsp; ` +
                        `H:<font color="${highlightColor}">${realData.high}</font> &nbsp;&nbsp; ` +
                        `L:<font color="${highlightColor}">${realData.low}</font> &nbsp;&nbsp; ` +
                        `C:<font color="${highlightColor}">${realData.close}</font> &nbsp;&nbsp; ` +
                        `Vol:<font color="${highlightColor}">${realData.volume.toFixed(0)}K</font>`
                                                ) : ``

                // Positions
                cursor_horizontal_line.y = mouse_y
            }

            // Block this function for a while to allow engine to render
            update_block_timer.start()
        }
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
