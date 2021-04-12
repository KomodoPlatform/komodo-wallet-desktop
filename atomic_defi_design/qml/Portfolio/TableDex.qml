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
    width: parent.width
    height: 500
    visible: true
    Item {
        anchors.fill: parent
        anchors.margins: 15
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        //radius: 2
        Rectangle {
            width: parent.width
            height: 60
            color:  Qt.darker(theme.backgroundColor, 0.8)
            // Coin
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
                            //anchors.horizontalCenter: parent.horizontalCenter
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
                            //text: qsTr("Trend 7d")
                            //anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        //text: qsTr("Trend 7d")
                        sort_type: sort_by_trend
                    }
                    DefaultText {
                        text: qsTr("Trend 7d")
                        //anchors.horizontalCenter: parent.horizontalCenter
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
//                Item {
//                    Layout.fillHeight: true
//                    Layout.fillWidth: true
//                }
            }

//            ColumnHeader {
//                id: coin_header
//                icon_at_left: true
//                anchors.left: parent.left
//                anchors.leftMargin: 40
//                anchors.verticalCenter: parent.verticalCenter

//                text: qsTr("Asset")
//                sort_type: sort_by_name
//            }

            // Balance
//            ColumnHeader {
//                id: balance_header
//                icon_at_left: true
//                anchors.left: parent.left
//                anchors.leftMargin: parent.width * 0.265
//                anchors.verticalCenter: parent.verticalCenter

//                text: qsTr("Balance")
//                sort_type: sort_by_value
//            }

            // Change 24h
//            ColumnHeader {
//                id: change_24h_header
//                icon_at_left: false
//                anchors.right: parent.right
//                anchors.rightMargin: parent.width * 0.37
//                anchors.verticalCenter: parent.verticalCenter

//                text: qsTr("Change 24h")
//                sort_type: sort_by_change
//            }

            // 7-day Trend
//            ColumnHeader {
//                id: trend_7d_header
//                icon_at_left: false
//                anchors.right: parent.right
//                anchors.rightMargin: parent.width * 0.2
//                anchors.verticalCenter: parent.verticalCenter

//                text: qsTr("Trend 7d")
//                sort_type: sort_by_trend
//            }

            // Price
//            ColumnHeader {
//                id: price_header
//                icon_at_left: false
//                anchors.right: parent.right
//                anchors.rightMargin: coin_header.anchors.leftMargin
//                anchors.verticalCenter: parent.verticalCenter

//                text: qsTr("Price")
//                sort_type: sort_by_price
//            }
        }
        DefaultListView {
            id: list
            visible: true
            y: 60
            width: parent.width
            height: parent.height - 50

            model: portfolio_coins
            cacheBuffer: 2000

            delegate: AnimatedRectangle {
                color: Qt.lighter(
                           mouse_area.containsMouse ? theme.hightlightColor : index % 2 !== 0 ? Qt.darker(theme.backgroundColor, 0.8) : "transparent",
                           mouse_area.containsMouse ? Style.hoverLightMultiplier : 1.0)
                //Qt.darker(theme.backgroundColor, 0.8)
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



                // Icon
//                DefaultImage {
//                    id: icon
//                    anchors.left: parent.left
//                    anchors.leftMargin: coin_header.anchors.leftMargin

//                    source: General.coinIcon(ticker)
//                    width: Style.textSize2
//                    anchors.verticalCenter: parent.verticalCenter
//                }

                // Name
//                DefaultText {
//                    id: coin_name
//                    anchors.left: icon.right
//                    anchors.leftMargin: 10
//                    text_value: name
//                    anchors.verticalCenter: parent.verticalCenter
//                }

//                CoinTypeTag {
//                    id: tag
//                    anchors.left: coin_name.right
//                    anchors.leftMargin: 10
//                    anchors.verticalCenter: parent.verticalCenter

//                    type: model.type

//                    opacity: 0.25

//                    visible: mouse_area.containsMouse
//                }

                // Balance
//                DefaultText {
//                    id: balance_value
//                    anchors.left: parent.left
//                    anchors.leftMargin: balance_header.anchors.leftMargin

//                    text_value: General.formatCrypto(
//                                    "", balance, ticker,
//                                    main_currency_balance,
//                                    API.app.settings_pg.current_currency)
//                    color: Qt.darker(theme.foregroundColor, 0.8)
//                    anchors.verticalCenter: parent.verticalCenter
//                    privacy: true
//                }

                // Change 24h
//                DefaultText {
//                    id: change_24h_value
//                    anchors.right: parent.right
//                    anchors.rightMargin: change_24h_header.anchors.rightMargin

//                    text_value: {
//                        const v = parseFloat(change_24h)
//                        return v === 0 ? '-' : General.formatPercent(
//                                             v)
//                    }
//                    color: Style.getValueColor(change_24h)
//                    anchors.verticalCenter: parent.verticalCenter
//                }

                // Price
//                DefaultText {
//                    id: price_value
//                    anchors.right: parent.right
//                    anchors.rightMargin: price_header.anchors.rightMargin

//                    text_value: General.formatFiat(
//                                    '',
//                                    main_currency_price_for_one_unit,
//                                    API.app.settings_pg.current_currency)
//                    color: theme.colorThemeDarkLight
//                    anchors.verticalCenter: parent.verticalCenter
//                }

//                DefaultImage {
//                    visible: API.app.portfolio_pg.oracle_price_supported_pairs.join(
//                                 ",").indexOf(ticker) !== -1
//                    source: General.coinIcon('BAND')
//                    width: 12
//                    height: width
//                    anchors.top: price_value.top
//                    anchors.left: price_value.right
//                    anchors.leftMargin: 5

//                    CexInfoTrigger {}
//                }

                // 7d Trend
//                ChartView {
//                    property var historical: trend_7d
//                    id: chart
//                    width: 200
//                    height: 100
//                    antialiasing: true
//                    anchors.right: parent.right
//                    anchors.rightMargin: trend_7d_header.anchors.rightMargin
//                                         - width * 0.4
//                    anchors.verticalCenter: parent.verticalCenter
//                    legend.visible: false

//                    function refresh() {
//                        updateChart(chart, historical,
//                                    Style.getValueColor(change_24h))
//                    }

//                    property bool dark_theme: Style.dark_theme
//                    onDark_themeChanged: refresh()
//                    onHistoricalChanged: refresh()
//                    backgroundColor: "transparent"
//                }
            }
        }
    }
}
