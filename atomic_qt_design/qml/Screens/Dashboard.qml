import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

import "../Portfolio"
import "../Wallet"
import "../Exchange"
import "../Settings"
import "../Sidebar"

Item {
    id: dashboard

    Layout.fillWidth: true

    function getMainPage() {
        return API.design_editor ? General.idx_dashboard_exchange : General.idx_dashboard_portfolio
    }

    property int prev_page: -1
    property int current_page: getMainPage()

    function reset() {
        current_page = getMainPage()
        prev_page = -1

        // Reset all sections
        portfolio.reset()
        wallet.reset()
        exchange.reset()
        news.reset()
        dapps.reset()
        settings.reset()
    }

    function inCurrentPage() {
        return app.current_page === idx_dashboard
    }

    function shouldUpdatePortfolio() {
        return  inCurrentPage() &&
                (current_page === General.idx_dashboard_portfolio ||
                 current_page === General.idx_dashboard_wallet)
    }

    property var portfolio_coins: ([])

    function updatePortfolio() {
        portfolio_coins = API.get().get_portfolio_informations()

        update_timer.running = true
    }

    Timer {
        id: update_timer
        running: false
        repeat: true
        interval: 5000
        onTriggered: {
            if(shouldUpdatePortfolio()) updatePortfolio()
        }
    }


    onCurrent_pageChanged: {
        if(prev_page !== current_page) {
            if(current_page === General.idx_dashboard_exchange) {
                API.get().on_gui_enter_dex()
                exchange.onOpened()
            }
            else if(prev_page === General.idx_dashboard_exchange) {
                API.get().on_gui_leave_dex()
            }

            if(current_page === General.idx_dashboard_portfolio) {
                portfolio.onOpened()
            }
            else if(current_page === General.idx_dashboard_wallet) {
                wallet.onOpened()
            }
            else if(current_page === General.idx_dashboard_settings) {
                settings.onOpened()
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

    // Sidebar, left side
    Sidebar {
        id: sidebar
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

            DefaultText {
                id: news
                text_value: API.get().empty_string + (qsTr("News"))
                function reset() { }
            }

            DefaultText {
                id: dapps
                text_value: API.get().empty_string + (qsTr("Dapps"))
                function reset() { }
            }

            Settings {
                id: settings
                Layout.alignment: Qt.AlignCenter
            }
        }
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
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
