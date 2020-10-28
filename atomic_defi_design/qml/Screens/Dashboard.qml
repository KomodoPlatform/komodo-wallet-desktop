import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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

    property alias notifications_modal: notifications_modal
    Layout.fillWidth: true

    function getMainPage() {
        return General.idx_dashboard_portfolio
    }

    function openLogsFolder() {
        API.app.export_swaps_json()
        Qt.openUrlExternally(General.os_file_prefix + API.app.get_log_folder())
    }

    readonly property var api_wallet_page: API.app.wallet_pg
    readonly property var current_ticker_infos: api_wallet_page.ticker_infos
    readonly property bool can_change_ticker: !api_wallet_page.tx_fetching_busy

    property int prev_page: -1
    property int current_page: getMainPage()

    readonly property bool is_dex_banned: !API.app.ip_checker.ip_authorized

    function reset() {
        // Fill all coins list
        General.all_coins = API.app.get_all_coins()

        current_page = getMainPage()
        prev_page = -1

        // Reset all sections
        portfolio.reset()
        wallet.reset()
        exchange.reset()
        addressbook.reset()
        news.reset()
        dapps.reset()
        settings.reset()
        notifications_modal.reset()
    }

    function inCurrentPage() {
        return app.current_page === idx_dashboard
    }

    readonly property var portfolio_mdl: API.app.portfolio_pg.portfolio_mdl
    property var portfolio_coins: portfolio_mdl.portfolio_proxy_mdl

    function resetCoinFilter() {
        portfolio_coins.setFilterFixedString("")
    }

    onCurrent_pageChanged: {
        if(prev_page !== current_page) {
            // Handle DEX enter/exit
            if(current_page === General.idx_dashboard_exchange) {
                API.app.trading_pg.on_gui_enter_dex()
                exchange.onOpened()
            }
            else if(prev_page === General.idx_dashboard_exchange) {
                API.app.trading_pg.on_gui_leave_dex()
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
        onTriggered: {
            General.enableParentCoinIfNeeded("ETH", "ERC-20")
            General.enableParentCoinIfNeeded("QTUM", "QRC-20")
        }
    }

    // Right side
    AnimatedRectangle {
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

            AddressBook {
                id: addressbook
            }

            Item {
                id: news
                function reset() { }
                Layout.fillWidth: true
                Layout.fillHeight: true
                DefaultText {
                    anchors.centerIn: parent
                    text_value: qsTr("Content for this section will be added later. Stay tuned!")
                }
            }

            Item {
                id: dapps
                function reset() { }
                Layout.fillWidth: true
                Layout.fillHeight: true
                DefaultText {
                    anchors.centerIn: parent
                    text_value: qsTr("Content for this section will be added later. Stay tuned!")
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

    // Unread notifications count
    AnimatedRectangle {
        radius: 1337
        width: count_text.height * 1.5
        height: width
        z: 1

        x: sidebar.app_logo.x + sidebar.app_logo.width - 20
        y: sidebar.app_logo.y
        color: Qt.lighter(notifications_modal.notifications_list.length > 0 ? Style.colorRed : Style.colorWhite7, notifications_modal_button.containsMouse ? Style.hoverLightMultiplier : 1)

        DefaultText {
            id: count_text
            anchors.centerIn: parent
            text_value: notifications_modal.notifications_list.length
            font.pixelSize: Style.textSizeSmall1
            font.weight: Font.Medium
            color: notifications_modal.notifications_list.length > 0 ? Style.colorWhite9 : Style.colorWhite12
        }
    }

    // Notifications panel button
    DefaultMouseArea {
        id: notifications_modal_button
        x: sidebar.app_logo.x
        y: sidebar.app_logo.y
        width: sidebar.app_logo.width
        height: sidebar.app_logo.height

        hoverEnabled: true

        onClicked: notifications_modal.open()
    }

    NotificationsModal {
        id: notifications_modal
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

    AddCustomCoinModal {
        id: add_custom_coin_modal
    }

    // CEX Rates info
    CexInfoModal {
        id: cex_rates_modal
    }

    RestartModal {
        id: restart_modal
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
