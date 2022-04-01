import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import "../../../Constants"
import "../../../Components"

Widget
{
    id: _control

    property real youGetColumnWidth: 0.5
    property real fiatPriceColumnWidth: 0.22
    property real cexRateColumnWidth: 0.22

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
