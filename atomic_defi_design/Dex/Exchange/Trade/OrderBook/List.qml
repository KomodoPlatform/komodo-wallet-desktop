import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0


Item
{
    id: _control

    property bool isAsk
    property bool isVertical: false
    width: parent.width
    height: parent.height

    ListView
    {
        id: orderbook_list
        width: parent.width
        height: parent.height
        model: isAsk ? API.app.trading_pg.orderbook.asks.proxy_mdl : API.app.trading_pg.orderbook.bids.proxy_mdl
        clip: true
        reuseItems: true
        spacing: 8

        onContentHeightChanged:
        {
            if (isVertical) _tm.start();
        }

        delegate: Item
        {
            width: orderbook_list.width
            height: 24

            ListDelegate
            {
                width: parent.width
                height: parent.height
                isAsk: _control.isAsk ? true : false
            }
        }

        Timer
        {
            id: _tm
            interval: 2000
            onTriggered:
            {
                orderbook_list.positionViewAtEnd()
            }
        }
    }
}