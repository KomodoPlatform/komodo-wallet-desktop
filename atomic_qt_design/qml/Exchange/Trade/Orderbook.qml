import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

InnerBackground {
    Item {
        anchors.fill: parent

        OrderbookSection {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: separator.left
            model: API.get().orderbook.bids.proxy_mdl
        }

        VerticalLine {
            id: separator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        OrderbookSection {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: separator.right

            is_asks: true
            model: API.get().orderbook.asks.proxy_mdl
        }
    }
}
