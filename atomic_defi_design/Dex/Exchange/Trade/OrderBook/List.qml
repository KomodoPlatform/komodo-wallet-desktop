import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0


Item
{
    id: _control

    property bool isAsk
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
        opacity: API.app.trading_pg.maker_mode ? 0.6 : 1

        onContentHeightChanged:
        {
            if (isAsk){
                // Duplication is intended. Sometimes data takes too long to load so slowscroll is a backup. 
                slowscroll_timer.start();
                quickscroll_timer.start()
            } 
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
            id: slowscroll_timer
            interval: 1500
            onTriggered:
            {
                orderbook_list.positionViewAtEnd()
            }
        }
        Timer
        {
            id: quickscroll_timer
            interval: 500
            onTriggered:
            {
                orderbook_list.positionViewAtEnd()
            }
        }
        onModelChanged: {
            if (isAsk) quickscroll_timer.start()
        }
    }

    Connections {
        target: API.app.trading_pg;

        function onMarketModeChanged()
        {
            if (isAsk)
            {
                quickscroll_timer.start()
            }
        }
        function onOrderbookChanged()
        {
            if (isAsk)
            {
                quickscroll_timer.start()
            }
        }
        function onMarketPairsChanged()
        {
            if (isAsk)
            {
                quickscroll_timer.start()
            }
        }
    }
}