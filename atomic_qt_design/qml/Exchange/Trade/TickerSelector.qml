import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0

import "../../Components"
import "../../Constants"

RowLayout {
    id: root

    spacing: 5
    Layout.preferredWidth: 250
    layoutDirection: my_side ? Qt.LeftToRight : Qt.RightToLeft

    property bool my_side: false
    property var ticker_list

    // Public
    function getTicker() {
        return my_side ? API.get().trading_pg.market_pairs_mdl.left_selected_coin :
                         API.get().trading_pg.market_pairs_mdl.right_selected_coin
    }

    // Private
    function getFilteredCoins() {
        return getCoins(my_side)
    }

    function getAnyAvailableCoin(filter_ticker) {
        let coins = getFilteredCoins().map(c => c.ticker)

        // Filter out ticker
        if(filter_ticker !== undefined || filter_ticker !== '')
            coins = coins.filter(c => c !== filter_ticker)

        // Pick a random one if prioritized ones do not satisfy
        return coins.length > 0 ? coins[0] : ''
    }

    DefaultImage {
        source: General.coinIcon(getTicker())
        Layout.preferredWidth: 32
        Layout.preferredHeight: Layout.preferredWidth
    }

    DefaultComboBox {
        id: combo

        model: ticker_list
        textRole: "display"
        valueRole: "ticker"
        onCurrentValueChanged: {
            setPair(my_side, currentValue)
        }

        Layout.fillWidth: true
    }
}
