import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"
import ".."

OrdersPage {
    page_index: idx_exchange_history

    title: qsTr("Recent Swaps")
    //empty_text: qsTr("You don't have recent orders.")
    is_history: true
}
