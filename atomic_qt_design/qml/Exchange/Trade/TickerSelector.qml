import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import "../../Components"
import "../../Constants"

RowLayout {
    id: root

    spacing: 5
    Layout.preferredWidth: 250
    layoutDirection: my_side ? Qt.LeftToRight : Qt.RightToLeft

    property bool my_side: false
    property var ticker_list: ([])
    property bool recursive_update: false

    // Public
    function setAnyTicker() {
        setTicker(getAnyAvailableCoin())
    }

    function fillIfEmpty() {
        if(getTicker() === '') setAnyTicker()
    }

    function update(new_ticker) {
        updateTickerList(new_ticker)
    }

    function getTicker() {
        return ticker_list.length > 0 ? ticker_list[combo.currentIndex].value : ""
    }

    function setTicker(ticker) {
        combo.currentIndex = getFilteredCoins().map(c => c.ticker).indexOf(ticker)

        // If it doesn't exist, pick an existing one
        if(combo.currentIndex === -1) setAnyTicker()
    }

    // Private
    Timer {
        id: update_timer
        running: inCurrentPage()
        repeat: true
        interval: 1000
        onTriggered: {
            if(inCurrentPage()) updateTickerList()
        }
    }

    function updateTickerList(new_ticker) {
        recursive_update = new_ticker !== undefined

        ticker_list = my_side ? General.getTickersAndBalances(getFilteredCoins()) : General.getTickers(getFilteredCoins())

        update_timer.running = true
    }

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

        Layout.fillWidth: true

        model: ticker_list

        textRole: "text"

        onCurrentTextChanged: {
            if(!recursive_update) {
                updateForms(my_side, combo.currentText)
                setPair(my_side)
            }
        }
    }
}
