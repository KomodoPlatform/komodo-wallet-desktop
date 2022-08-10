import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Constants"
import "../../../Components"
import App 1.0 as App
import AtomicDEX.MarketMode 1.0
import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex

Widget
{
    id: _control
    title: qsTr("Best Orders")
    margins: 20
    spacing: 20

    Header {}

    Dex.ListView
    {
        id: _listView
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 6

        model: API.app.trading_pg.orderbook.best_orders.proxy_mdl

        clip: true
        reuseItems: true
        scrollbar_visible: false

        delegate: ListDelegate
        {
            width: _listView.width
            height: 30
        }
    }
}
