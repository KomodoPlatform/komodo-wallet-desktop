import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../Components"
import "../Constants"
import "../Screens"
import App 1.0

RowLayout
{
    id: wallet

    property alias send_modal: main.send_modal

    function inCurrentPage()
    {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === idx_dashboard_wallet
    }

    // Local
    function onClickedSwap()
    {
        dashboard.switchPage(Dashboard.PageType.DEX)
        dashboard.current_ticker = api_wallet_page.ticker
        API.app.trading_pg.set_pair(true, api_wallet_page.ticker)
    }

    function reset()
    {
        sidebar.reset()
    }

    readonly property double button_margin: 0.05

    spacing: 0
    Layout.fillWidth: true
    Component.onCompleted:
    {
        API.app.wallet_pg.page_open = true
        reset()
    }
    Component.onDestruction: API.app.wallet_pg.page_open = false

    // Coins bar at left side
    Sidebar
    {
        id: sidebar
    }

    // Right side, main
    Main
    {
        id: main
    }
}
