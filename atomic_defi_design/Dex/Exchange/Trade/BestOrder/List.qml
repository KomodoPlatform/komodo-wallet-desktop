import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Constants"
import "../../../Components"
import App 1.0 as App
import AtomicDEX.MarketMode 1.0
import Dex.Themes 1.0 as Dex


Widget
{
    id: _control

    property real row_height: 36
    property real youGetColumnWidth: 160
    property real fiatPriceColumnWidth: 70
    property real cexRateColumnWidth: 70

    title: qsTr("Best Orders")

    margins: 20
    spacing: 20

    Header
    {
        Layout.topMargin: 10
        Layout.fillWidth: true
    }

    ListView
    {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: API.app.trading_pg.orderbook.best_orders.proxy_mdl
        spacing: 6
        clip: true

        delegate: ListDelegate
        {
            width: list.width
            height: 36
        }
    }
}