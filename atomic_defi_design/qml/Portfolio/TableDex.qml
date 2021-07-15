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

Item {
    property alias innerList: list

    width: parent.width
    height: 150+(list.count*65)
    visible: true
    Item {
        anchors.fill: parent
        anchors.margins: 15
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        Rectangle {
            width: parent.width
            height: 60
            color:  Qt.darker(theme.backgroundColor, 0.8)
            RowLayout {
                anchors.fill: parent
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    ColumnHeader {
                        id: coin_header
                        icon_at_left: true
                        anchors.left: parent.left
                        anchors.leftMargin: 40
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Asset")
                        sort_type: sort_by_name
                    }
                }
                Item {
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true

                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Qaterial.DebugRectangle {
                        anchors.fill: parent
                        visible: false
                    }

                    ColumnHeader {
                        id: balance_header
                        icon_at_left: true
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Balance")
                        sort_type: sort_by_value
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 140
                    Qaterial.DebugRectangle {
                        anchors.fill: parent
                        visible: false
                    }
                    ColumnHeader {
                        id: change_24h_header
                        icon_at_left: false
                        anchors.verticalCenter: parent.verticalCenter

                        //text: qsTr("Change 24h")
                        DefaultText {
                            id: title
                            text: qsTr("Change 24h")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        sort_type: sort_by_change
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    visible: app.width>1370
                    Qaterial.DebugRectangle {
                        anchors.fill: parent
                        visible: false
                    }
                    ColumnHeader {
                        id: trend_7d_header
                        icon_at_left: false
                        anchors.verticalCenter: parent.verticalCenter
                        DefaultText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        sort_type: sort_by_trend
                    }
                    DefaultText {
                        text: qsTr("Trend 7d")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 140
                    ColumnHeader {
                        id: price_header
                        icon_at_left: false
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        text: qsTr("Price")
                        sort_type: sort_by_price
                    }
                }
            }
        }
        DefaultListView {
            id: list
            visible: true
            y: 60
            width: parent.width
            height: parent.height - 50
            interactive: false
            model: portfolio_coins
            cacheBuffer: 2000
            scrollbar_visible: false

            delegate: AnimatedRectangle {
                color: Qt.lighter(
                           mouse_area.containsMouse ? theme.hightlightColor : index % 2 !== 0 ? Qt.darker(theme.backgroundColor, 0.8) : "transparent",
                           mouse_area.containsMouse ? Style.hoverLightMultiplier : 1.0)
                width: list.width
                height: 65
                AnimatedRectangle {
                    id: main_color
                    color: Style.getCoinColor(ticker)
                    width: 10
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    visible: false
                }

                // Click area
                DefaultMouseArea {
                    id: mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if (!can_change_ticker)
                            return

                        if (mouse.button === Qt.RightButton)
                            context_menu.popup()
                        else {
                            api_wallet_page.ticker = ticker
                            dashboard.current_page = idx_dashboard_wallet
                        }
                    }
                    onPressAndHold: {
                        if (!can_change_ticker)
                            return

                        if (mouse.source === Qt.MouseEventNotSynthesized)
                            context_menu.popup()
                    }
                }

                // Right click menu
                CoinMenu {
                    id: context_menu
                }
                RowLayout {
                    anchors.fill: parent
                    spacing: 5
                    Item {
                        Layout.preferredWidth: 50
                        Layout.fillHeight: true
                        DefaultImage {
                            id: icon
                            source: General.coinIcon(ticker)
                            width: Style.textSize2
                            anchors.centerIn: parent
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        DefaultText {
                            id: coin_name
                            text_value: name
                            bottomPadding: 20
                            font: theme.textType.body2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        DefaultText {
                            id: type_tag
                            anchors.bottom: coin_name.bottom

                            text: model.type
                            font: theme.textType.overLine
                            opacity: .7
                            color: Style.getCoinTypeColor(model.type)
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Qaterial.DebugRectangle {
                            anchors.fill: parent
                            visible: false
                        }
                        DefaultText {
                            id: balance_value
                            font: theme.textType.body2

                            text_value: General.formatCrypto(
                                            "", balance, ticker,
                                            main_currency_balance,
                                            API.app.settings_pg.current_currency)
                            color: Qt.darker(theme.foregroundColor, 0.8)
                            anchors.verticalCenter: parent.verticalCenter
                            privacy: true
                        }

                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 140
                        Qaterial.DebugRectangle {
                            anchors.fill: parent
                            visible: false
                        }
                        DefaultText {
                            id: change_24h_value
                            font: theme.textType.body2
                            text_value: {
                                const v = parseFloat(change_24h)
                                return v === 0 ? '-' : General.formatPercent(
                                                     v)
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Style.getValueColor(change_24h)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: app.width>1370
                        Qaterial.DebugRectangle {
                            anchors.fill: parent
                            visible: false
                        }
                        ChartView {
                            property var historical: trend_7d
                            id: chart
                            width: 200
                            height: 100
                            antialiasing: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            legend.visible: false

                            function refresh() {
                                updateChart(chart, historical,
                                            Style.getValueColor(change_24h))
                            }

                            property bool dark_theme: Style.dark_theme
                            onDark_themeChanged: refresh()
                            onHistoricalChanged: refresh()
                            backgroundColor: "transparent"
                        }


                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 140
                        DefaultText {
                            id: price_value
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            font: theme.textType.body2

                            text_value: General.formatFiat(
                                            '',
                                            main_currency_price_for_one_unit,
                                            API.app.settings_pg.current_currency)
                            color: theme.colorThemeDarkLight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        DefaultImage {
                            visible: API.app.portfolio_pg.oracle_price_supported_pairs.join(
                                         ",").indexOf(ticker) !== -1
                            source: General.coinIcon('BAND')
                            width: 12
                            height: width
                            anchors.left: parent.right
                            anchors.leftMargin: 5

                            CexInfoTrigger {}
                        }
                    }
                }
            }
            footer: Item {
                width: parent.width
                height: 60
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width-2
                    height: parent.height-2
                    color: 'transparent'
                    border.color: theme.foregroundColor
                    opacity: .15
                    radius: 4
                }
                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    opacity: .5
                    Qaterial.ColorIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        source: Qaterial.Icons.plusBox
                    }
                    DexLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Add new asset"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"
                    onClicked: enable_coin_modal.open()
                }
            }
        }
    }
}
