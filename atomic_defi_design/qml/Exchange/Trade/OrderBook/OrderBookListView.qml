import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import "../../../Constants/"


Item {
    id: _control
    property bool isAsk
    OrderbookHeader {
        is_ask: isAsk
    }

    ListView {
        id: orderList
        anchors.topMargin: 40
        anchors.fill: parent
        model: isAsk? API.app.trading_pg.orderbook.asks.proxy_mdl : API.app.trading_pg.orderbook.bids.proxy_mdl
        clip: true
        snapMode: ListView.SnapToItem
        headerPositioning: ListView.OverlayHeader
        Component.onCompleted: {
            positionViewAtEnd()
        }

        delegate: OrderBookDelegate {
            isAsk: _control.isAsk? true : false
        }
    }
}
