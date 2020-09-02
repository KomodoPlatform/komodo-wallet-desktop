import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

import "../Dashboard"
import "../Portfolio"
import "../Wallet"
import "../Exchange"
import "../Settings"
import "../Support"
import "../Sidebar"

Item {
    id: dashboard

    Layout.fillWidth: true

    function getMainPage() {
        return API.design_editor ? General.idx_dashboard_wallet : General.idx_dashboard_portfolio
    }

    function openLogsFolder() {
        API.get().export_swaps_json()
        const prefix = Qt.platform.os == "windows" ? "file:///" : "file://"
        Qt.openUrlExternally(prefix + API.get().get_log_folder())
    }

    readonly property var current_ticker_infos: API.get().wallet_pg.ticker_infos

    property int prev_page: -1
    property int current_page: getMainPage()

    function reset() {
        // Fill all coins list
        General.all_coins = API.get().get_all_coins()

        current_page = getMainPage()
        prev_page = -1

        // Reset all sections
        portfolio.reset()
        wallet.reset()
        exchange.reset()
        news.reset()
        dapps.reset()
        settings.reset()
        notifications_panel.reset()
    }

    function inCurrentPage() {
        return app.current_page === idx_dashboard
    }

    property var portfolio_coins: API.get().portfolio_pg.portfolio_mdl.portfolio_proxy_mdl

    function resetCoinFilter() {
        portfolio_coins.setFilterFixedString("")
    }

    onCurrent_pageChanged: {
        if(prev_page !== current_page) {
            // Handle DEX enter/exit
            if(current_page === General.idx_dashboard_exchange) {
                API.get().trading_pg.on_gui_enter_dex()
                exchange.onOpened()
            }
            else if(prev_page === General.idx_dashboard_exchange) {
                API.get().trading_pg.on_gui_leave_dex()
            }

            // Opening of other pages
            if(current_page === General.idx_dashboard_portfolio) {
                portfolio.onOpened()
            }
            else if(current_page === General.idx_dashboard_wallet) {
                wallet.onOpened()
            }
            else if(current_page === General.idx_dashboard_settings) {
                settings.onOpened()
            }
            else if(current_page === General.idx_dashboard_support) {
                support.onOpened()
            }
        }

        prev_page = current_page
    }

    Timer {
        running: inCurrentPage()
        interval: 1000
        repeat: true
        onTriggered: General.enableEthIfNeeded()
    }
    // Right side
    Rectangle {
        color: Style.colorTheme8
        width: parent.width - sidebar.width
        height: parent.height
        x: sidebar.width

        // Modals
        EnableCoinModal {
            id: enable_coin_modal
            anchors.centerIn: Overlay.overlay
        }

        StackLayout {
            currentIndex: current_page

            anchors.fill: parent

            transformOrigin: Item.Center

            Portfolio {
                id: portfolio
            }

            Wallet {
                id: wallet
            }

            Exchange {
                id: exchange
            }

            Item {
                id: news
                function reset() { }
                Layout.fillWidth: true
                Layout.fillHeight: true
                DefaultText {
                    anchors.centerIn: parent
                    text_value: API.get().settings_pg.empty_string + (qsTr("Content for this section will be added later. Stay tuned!"))
                }
            }

            Item {
                id: dapps
                function reset() { }
                Layout.fillWidth: true
                Layout.fillHeight: true
                DefaultText {
                    anchors.centerIn: parent
                    text_value: API.get().settings_pg.empty_string + (qsTr("Content for this section will be added later. Stay tuned!"))
                }
            }

            Settings {
                id: settings
                Layout.alignment: Qt.AlignCenter
            }

            Support {
                id: support
                Layout.alignment: Qt.AlignCenter
            }
        }
    }

    // Sidebar, left side
    Sidebar {
        id: sidebar
    }

    // Global click
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        onClicked: mouse.accepted = false
        onReleased: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPositionChanged: mouse.accepted = false
        onPressed: {
            // Close notifications panel on outside click
            if(notifications_panel.visible)
                notifications_panel.visible = false

            mouse.accepted = false
        }
    }

    // Unread notifications count
    Rectangle {
        radius: 1337
        width: count_text.height * 1.5
        height: width
        z: 1

        x: sidebar.app_logo.x + sidebar.app_logo.width - 20
        y: sidebar.app_logo.y
        color: notifications_panel.notifications_list.length > 0 ? Style.colorRed : Style.colorWhite7

        DefaultText {
            id: count_text
            anchors.centerIn: parent
            text_value: notifications_panel.notifications_list.length
            font.pixelSize: Style.textSizeSmall1
            font.bold: true
            color: notifications_panel.notifications_list.length > 0 ? Style.colorWhite9 : Style.colorWhite12
        }
    }

    // Notifications panel button
    MouseArea {
        x: sidebar.app_logo.x
        y: sidebar.app_logo.y
        width: sidebar.app_logo.width
        height: sidebar.app_logo.height

        onClicked: notifications_panel.visible = !notifications_panel.visible
    }

    NotificationsPanel {
        id: notifications_panel
        width: 600
        height: 500
        anchors.left: sidebar.right
        anchors.top: parent.top
    }

    DropShadow {
        anchors.fill: sidebar
        source: sidebar
        cached: false
        horizontalOffset: 0
        verticalOffset: 0
        radius: 32
        samples: 32
        spread: 0
        color: Style.colorSidebarDropShadow
        smooth: true
    }

    // CEX Rates info
    DefaultModal {
        id: cex_rates_modal
        width: 900

        // Inside modal
        ColumnLayout {
            width: parent.width - parent.padding

            ModalHeader {
                title: API.get().settings_pg.empty_string + (General.cex_icon + " " + qsTr("Market Data"))
            }

            DefaultText {
                text_value: API.get().settings_pg.empty_string + (qsTr('Market data (prices, charts, etc.) marked with the ⓘ icon originates from third-party sources.<br><br>Data is sourced via <a href="https://bandprotocol.com/">Band Decentralized Oracle</a> and <a href="https://coinpaprika.com">Coinpaprika</a>.<br><br><b>Oracle Supported Pairs:</b><br>%1<br><br><b>Last reference (Band Oracle):</b><br><a href="%2">%2</a>')
                                                                    .arg(API.get().portfolio_pg.oracle_price_supported_pairs.join(', '))
                                                                    .arg(API.get().portfolio_pg.oracle_last_price_reference))
                wrapMode: Text.WordWrap
                Layout.preferredWidth: cex_rates_modal.width
            }
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
