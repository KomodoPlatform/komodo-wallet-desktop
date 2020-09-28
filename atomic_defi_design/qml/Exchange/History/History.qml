import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"
import ".."

OrdersPage {
    page_index: General.idx_exchange_history

    title: API.app.settings_pg.empty_string + (filter_enabled ? qsTr("Filtered Swaps") : qsTr("Recent Swaps"))
    empty_text: API.app.settings_pg.empty_string + (qsTr("You don't have recent orders."))
    is_history: true
}
