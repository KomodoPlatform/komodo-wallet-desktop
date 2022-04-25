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
    property real youGetColumnWidth: 0.35
    property real fiatPriceColumnWidth: 0.32
    property real cexRateColumnWidth: 0.32

    title: qsTr("Best Orders")

    margins: 20
    spacing: 20

    Header
    {
        Layout.fillWidth: true
        Layout.preferredHeight: 30
    }

    ListView
    {
        id: bestorders_list
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: API.app.trading_pg.orderbook.best_orders.proxy_mdl

        spacing: 6
        clip: true
        reuseItems: true

        delegate: ListDelegate
        {
            width: bestorders_list.width
            height: 36
        }
    }
}