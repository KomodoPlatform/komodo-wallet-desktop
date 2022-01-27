import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import "../../../Constants"
import "../../../Components"

Rectangle
{
    id: _control
    color: Dex.CurrentTheme.floatingBackgroundColor
    radius: 10

    ColumnLayout
    {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 20

        DefaultText
        {
            text: qsTr("Best Orders")
            font: DexTypo.subtitle1
        }

        Header {}

        ListView
        {
            id: list
            model: API.app.trading_pg.orderbook.best_orders.proxy_mdl
            clip: true
            reuseItems: true
            delegate: ListDelegate {}
        }
    }
}
