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
Item {
    property alias pieTimer2: pieTimer
    function refresh() {
        pieSeries.clear()
        for (var i = 0; i < portfolio_mdl.pie_chart_proxy_mdl.rowCount(); i++) {
            let data = portfolio_mdl.pie_chart_proxy_mdl.get(i)
            addItem(data)
        }
    }
    function addItem(value) {
        var item = pieSeries.append(value.ticker, value.main_currency_balance)
        item.labelColor = 'white'
        item.color = Qt.lighter(Style.getCoinColor(value.ticker))
        item.borderColor = theme.backgroundColor
        item.borderWidth = 2
        item.holeSize = 1
        item.labelFont = theme.textType.body2
        item.hovered.connect(function (state) {
            if (state) {
                item.explodeDistanceFactor = 0.01
                portfolio.currentTotal = API.app.settings_pg.current_fiat_sign+" "+ value.main_currency_balance
                portfolio.currentValue = value.balance + " " + item.label
                item.color = Qt.lighter(Qt.lighter(Style.getCoinColor(value.ticker)))
            } else {
                item.explodeDistanceFactor = 0.01
                portfolio.currentValue = ""
                portfolio.currentTotal = ""
                item.color = Style.getCoinColor(value.ticker)
            }
        })
    }
    Timer {
        id: pieTimer
        interval: 500
        onTriggered: {
            refresh()
        }
    }
    FloatingBackground {
        y: 35
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        ChartView {
            width: 550
            height: 500
            theme: ChartView.ChartView.ChartThemeLight
            antialiasing: true
            legend.visible: false
            smooth: true
            scale: portfolio.isUltraLarge? 1: 0.6
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                }
            }
            y: portfolio.isUltraLarge? -55:-150
            backgroundColor: 'transparent'

            anchors.horizontalCenter: parent.horizontalCenter
            dropShadowEnabled: true

            PieSeries {
                id: pieSeries
            }
            Rectangle {
                anchors.centerIn: parent
                color: theme.backgroundColor
                width: 295
                height: width
                radius: width/2
                //border.color: theme.accentColor
                //border.width: 2
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    DefaultText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: currentTotal !== "" ? currentTotal : General.formatFiat("", API.app.portfolio_pg.balance_fiat_all, API.app.settings_pg.current_currency)
                        font: theme.textType.head4
                        color: Qt.lighter(
                                   Style.colorWhite4,
                                   currency_change_button.containsMouse ? Style.hoverLightMultiplier : 1.0)
                        privacy: true
                        DexFadebehavior on text {
                            fadeDuration: 100
                        }
                        Component.onCompleted: {
                            font.family = 'Lato'
                        }
                    }
                    DefaultText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: portfolio.currentValue
                        font: theme.textType.body2
                        DexFadebehavior on text {
                            fadeDuration: 100
                        }
                        color: Qt.lighter(
                                   theme.foregroundColor, 0.6)
                        privacy: true
                        Component.onCompleted: {
                            font.family = 'Lato'
                        }
                    }
                    DefaultText {
                        id: count_label
                        anchors.horizontalCenter: parent.horizontalCenter
                        text_value: portfolio_helper.count + " " + qsTr(
                                        "Assets")
                        font: theme.textType.body2
                        DexFadebehavior on text {
                            fadeDuration: 100
                        }
                        color: Qt.lighter(
                                   theme.foregroundColor, 0.8)
                        privacy: true
                        visible: portfolio.currentValue == ""

                        Component.onCompleted: {
                            font.family = 'Lato'
                        }
                    }
                }
                DefaultMouseArea {
                    id: currency_change_button

                    width: parent.width - 100
                    height: parent.height - 100
                    anchors.centerIn: parent

                    hoverEnabled: true
                    onClicked: {
                        const current_fiat = API.app.settings_pg.current_currency
                        const available_fiats = API.app.settings_pg.get_available_currencies()
                        const current_index = available_fiats.indexOf(
                                                current_fiat)
                        const next_index = (current_index + 1)
                                         % available_fiats.length
                        const next_fiat = available_fiats[next_index]
                        API.app.settings_pg.current_currency = next_fiat
                    }
                }
            }
            Rectangle {
            anchors.centerIn: parent
            width: 295
            height: width
            color: 'transparent'
            radius: width/2
            border.width: API.app.portfolio_pg.balance_fiat_all>0 ? 0 : 5
            border.color: Qt.lighter(theme.backgroundColor)
        }
        }
        


        Item {
            scale: portfolio.isUltraLarge? 1: 0.8
            y: portfolio.isUltraLarge? 380 : 170
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                }
            }

            width: portfolio.isUltraLarge? parent.width - 50 : parent.width+20
            height: 200
            Qaterial.DebugRectangle {
                anchors.fill: parent
                visible: false
            }

            anchors.horizontalCenter: parent.horizontalCenter
            Flickable {
                anchors.fill: parent
                contentHeight: colo.height
                clip: true
                Column {
                    width: parent.width
                    id: colo
                    Repeater {
                        model: portfolio_mdl.pie_chart_proxy_mdl

                        RowLayout {
                            id: rootItem
                            property color itemColor: Style.getCoinColor(
                                                          ticker)
                            width: parent.width
                            height: 50
                            spacing: 20
                            DexLabel {
                                Layout.preferredWidth: 60
                                text: atomic_qt_utilities.retrieve_main_ticker(
                                          ticker)
                                Layout.alignment: Qt.AlignVCenter
                                Component.onCompleted: font.weight = Font.Medium
                            }
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: true
                                height: 8
                                radius: 10
                                color: theme.dexBoxBackgroundColor
                                Rectangle {
                                    height: parent.height
                                    width: (parseFloat(percent_main_currency) * parent.width) / 100
                                    radius: 10
                                    color: rootItem.itemColor
                                }
                            }

                            DexLabel {
                                text: percent_main_currency +" %"
                                Component.onCompleted: font.family = 'lato'
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }
                }
            }

            Qaterial.DebugRectangle {
                anchors.fill: parent
                visible: false
            }
        }
    }
}
