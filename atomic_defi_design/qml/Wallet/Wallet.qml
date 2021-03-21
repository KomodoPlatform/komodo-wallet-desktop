import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

    property alias send_modal: main.send_modal

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === idx_dashboard_wallet
    }

    // Local
    function onClickedSwap() {
        API.app.trading_pg.set_pair(true, api_wallet_page.ticker)
        dashboard.current_page = idx_dashboard_exchange
    }

    function reset() {
        main.reset()
        sidebar.reset()
    }

    Component.onCompleted: reset()

    readonly property double button_margin: 0.05
    spacing: 0
    Layout.fillWidth: true

    // Coins bar at left side
    Sidebar {
        id: sidebar
    }

    // Right side, main
    Main {
        id: main
    }
}

