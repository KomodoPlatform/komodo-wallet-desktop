import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import "../../../Constants/"


Item {
    id: _control
    property bool isAsk
    property bool isVertical: false
    Header {
        is_ask: isAsk
    }

    ListView {
        id: orderList
        anchors.topMargin: 40
        anchors.fill: parent
        model: isAsk? API.app.trading_pg.orderbook.asks.proxy_mdl : API.app.trading_pg.orderbook.bids.proxy_mdl
        clip: true
        reuseItems: true

        Timer {
            id: _tm
            interval: 2000
            onTriggered: orderList.positionViewAtEnd()
        }

        onCountChanged : {
            if(isVertical) {
                _tm.start()
            }
        }

        delegate: ListDelegate {
            isAsk: _control.isAsk? true : false
        }
    }
}
