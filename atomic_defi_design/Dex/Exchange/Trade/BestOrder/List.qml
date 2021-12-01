import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0


Item {
    id: _control
    Header {}

    ListView {
        id: list
        anchors.topMargin: 40
        anchors.fill: parent
        model: API.app.trading_pg.orderbook.best_orders.proxy_mdl
        clip: true
        reuseItems: true
        delegate: ListDelegate  {}
    }
}
