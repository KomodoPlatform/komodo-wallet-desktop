import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Open Enable Coin Modal
FloatingBackground {
    RowLayout {
        anchors.fill: parent
        spacing: 0

        OrderbookSection {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: API.get().orderbook.asks
        }

        VerticalLine {
            Layout.fillHeight: true
        }

        OrderbookSection {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: API.get().orderbook.bids
        }
    }
}
