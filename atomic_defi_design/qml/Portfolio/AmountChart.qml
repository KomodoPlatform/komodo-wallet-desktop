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
import "../Constants"

// Portfolio
InnerBackground {
    id: portfolio_asset_chart
    property bool isProgress: false
    function drawChart() {
        areaLine.clear()
        areaLine3.clear()
        //scatter.clear()

        dateA.min = new Date(API.app.portfolio_pg.charts[0].timestamp*1000)
        dateA.max = new Date(API.app.portfolio_pg.charts[API.app.portfolio_pg.charts.length-1].timestamp*1000)
        chart_2.update()
        for (let ii =0; ii<API.app.portfolio_pg.charts.length; ii++) {
            let el = API.app.portfolio_pg.charts[ii]
            try {
                //console.log("timestamp: " + el.timestamp*1000)
                areaLine3.append(el.timestamp*1000, parseFloat(el.total))
                areaLine.append(el.timestamp*1000, parseFloat(el.total))
                //scatter.append(el.timestamp*1000, parseFloat(el.total))
            }catch(e) {}
        }
        chart_2.update()
        portfolio_asset_chart.isProgress = false

    }

    Timer {
        id: pieTimer
        interval: 500
        onTriggered: {
            refresh()
        }
    }
    Timer {
        id: chart2Timer
        interval: 500
        onTriggered: {
            if(parseFloat(API.app.portfolio_pg.balance_fiat_all)>0){
                if(API.app.portfolio_pg.charts.length===0){
                    restart()
                }else {
                    portfolio_asset_chart.isProgress = false
                    drawTimer.restart()
                }
            }  
            
        }
    }
    Timer {
        id: drawTimer
        interval: 2000
        onTriggered: portfolio_asset_chart.drawChart()
    }
    Connections {
        target: API.app.portfolio_pg
        function onChart_busy_fetchingChanged() {
            if(!API.app.portfolio_pg.chart_busy_fetching){
                portfolio_asset_chart.isProgress = false
                chart2Timer.restart()
            }
        }
    }

    Component.onCompleted: {
        portfolio_asset_chart.isProgress = false
        //  chart2Timer.restart()
    }
    property real mX: 0
    property real mY: 0
    ClipRRect {
        anchors.fill: parent
        radius: parent.radius


        ChartView {
            id: chart_2
            anchors.fill: parent
            anchors.margins: -20
            anchors.topMargin: 50
            anchors.bottomMargin: 5
            theme: ChartView.ChartThemeLight
            antialiasing: true
            legend.visible: false
            backgroundColor: 'transparent'
            dropShadowEnabled: true
            margins.bottom: 5

            opacity: .8
            AreaSeries {
                id: area
                axisX: DateTimeAxis {
                    id: dateA
                    gridVisible: false
                    lineVisible: false
                    format: "<br>MMM d"
                    labelsColor: theme.foregroundColor
                }
                axisY: ValueAxis {
                    lineVisible: false
                    max:  parseFloat(API.app.portfolio_pg.max_total_chart)
                    min:  parseFloat(API.app.portfolio_pg.min_total_chart)
                    labelsColor: theme.foregroundColor  
                    gridLineColor: theme.chartGridLineColor
                }
                color: Qt.rgba(77,198,255,0.02)
                borderColor: 'transparent'


                upperSeries: LineSeries {
                    id: areaLine
                    axisY: ValueAxis {
                        visible: false
                        max:  parseFloat(API.app.portfolio_pg.max_total_chart)
                        min:  parseFloat(API.app.portfolio_pg.min_total_chart)
                        color: theme.foregroundColor
                    }
                    axisX: DateTimeAxis {
                        id: dateA2
                        min: dateA.min
                        max: dateA.max
                        gridVisible: false
                        lineVisible: false
                        format: "MMM d"
                    }

                }
            }
            Qaterial.ClipRRect {
                width: parent.width-110
                anchors.horizontalCenterOffset: 10
                height: parent.height
                
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    id: verticalLine
                    height: parent.height-84
                    opacity: .7
                    visible: mouse_area.containsMouse  && mouse_area.mouseX>60
                    anchors.verticalCenterOffset: -6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    radius: 4
                    
                    border.color: theme.accentColor
                    color: theme.foregroundColor
                    x: mouse_area.mouseX-80
                }
            }
            
            LineSeries {
                id: areaLine3
                color: theme.accentColor
                visible: !isSpline
                width: 3.0
                axisY: ValueAxis {
                    visible: false
                    max:  parseFloat(API.app.portfolio_pg.max_total_chart)
                    min:  parseFloat(API.app.portfolio_pg.min_total_chart)
                    gridLineColor: 'red'
                    labelsColor: 'red'//theme.foregroundColor
                }
                axisX: DateTimeAxis {
                    visible: false
                    min: dateA.min
                    max: dateA.max
                    gridVisible: false
                    lineVisible: false
                    format: "MMM d"
                    gridLineColor: 'red'
                    labelsColor: 'red'//theme.foregroundColor
                }
            }
            MouseArea {
                id: mouse_area
                width: parent.width+200
                height: parent.height
                x: -40
                enabled: false 
                hoverEnabled: false
                onPositionChanged:  {
                    let mx = mouseX
                    //console.log(mx)
                    let point = Qt.point(mx, mouseY)
                    let p = chart_2.mapToValue(point, area)
                    let idx = API.app.portfolio_pg.get_neareast_point(Math.floor(p.x) / 1000);
                    let pos = areaLine3.at(idx);
                    let chartPosition = chart_2.mapToPosition(pos, areaLine3)
                    
                    if(mx<170) {
                         boxi.x = mx
                    }else {
                        boxi.x = mx-170
                    }

                    boxi.y = chartPosition.y+10
                    boxi.value = pos.y
                    boxi.timestamp = pos.x
                }
            }
        }
       
      

        Rectangle {
            anchors.fill: parent
            opacity: .6
            color: theme.dexBoxBackgroundColor
            visible: portfolio_asset_chart.isProgress
            radius: parent.radius
            DexBusyIndicator {
                anchors.centerIn: parent
                running: visible
                visible: portfolio_asset_chart.isProgress && parseFloat(API.app.portfolio_pg.balance_fiat_all)>0
            }
        }

        Row {
            y: 15
            x: -20
            spacing: 20
            scale: .8
            FloatingBackground {
                width: rd.width+10
                height: 50

                Row {
                    id: rd
                    anchors.verticalCenter: parent.verticalCenter
                    x: 5
                    layoutDirection: Qt.RightToLeft

                    Qaterial.OutlineButton {
                        text: "YTD"
                        foregroundColor: theme.foregroundColor
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 3? theme.accentColor : theme.backgroundColor
                        onClicked: {
                            API.app.portfolio_pg.chart_category = WalletChartsCategories.Ytd
                        }
                    }
                    Qaterial.OutlineButton {
                        text: "1M"
                        foregroundColor: theme.foregroundColor
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 2? theme.accentColor : theme.backgroundColor
                        onClicked: {
                            API.app.portfolio_pg.chart_category = WalletChartsCategories.OneMonth
                        }
                    }
                    Qaterial.OutlineButton {
                        text: "7D"
                        foregroundColor: theme.foregroundColor
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 1? theme.accentColor : theme.backgroundColor
                        onClicked: API.app.portfolio_pg.chart_category = WalletChartsCategories.OneWeek
                    }
                    Qaterial.OutlineButton {
                        text: "24H"
                        opacity: .4
                        foregroundColor: theme.foregroundColor
                        enabled: false
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 0? theme.accentColor : theme.backgroundColor
                        onClicked: API.app.portfolio_pg.chart_category = 0
                    }
                }
            }
        }

        FloatingBackground {
            id: boxi
            property real value: 0
            property var timestamp
            visible:  mouse_area.containsMouse && mouse_area.mouseX>60
            width: 130
            height: 60
            x: 99999
            y: 99999

            Behavior on x {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 200
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                x: 10
                spacing: 5
                DexLabel {
                    text: "%1 %2".arg( API.app.settings_pg.current_fiat_sign).arg(boxi.value)
                    color: theme.accentColor
                    font: theme.textType.subtitle2
                }
                DexLabel {
                    text: Qt.formatDate(new Date(boxi.timestamp), "dd MMM yyyy");
                    font: theme.textType.body2
                }
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        opacity: 0.7
        color: "black"
        Column {
            anchors.centerIn: parent
            spacing: 20
            Qaterial.ColorIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                source: Qaterial.Icons.rocketLaunchOutline
                color: theme.accentColor
            }
            DexLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Work in progress")
            }
        }
    }
}
