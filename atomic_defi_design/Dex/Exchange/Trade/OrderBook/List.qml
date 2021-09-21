import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0


Item {
    id: _control
    property bool hide_header: false
    property bool isAsk
    property bool isVertical: false
    Header {
        visible: !hide_header
        is_ask: isAsk
    }

    ListView {
        id: orderList
        anchors.topMargin: hide_header? 0 : 40
        anchors.fill: parent
        model: isAsk? API.app.trading_pg.orderbook.asks.proxy_mdl : API.app.trading_pg.orderbook.bids.proxy_mdl
        clip: true
        reuseItems: true

        Timer {
            id: _tm
            interval: 2000
            onTriggered: {
                orderList.positionViewAtEnd()
            }
        }
        onContentHeightChanged : {
            if(isVertical) {
                _tm.start()
            }
        }

        delegate: ListDelegate {
            isAsk: _control.isAsk? true : false
        }
    }
}
