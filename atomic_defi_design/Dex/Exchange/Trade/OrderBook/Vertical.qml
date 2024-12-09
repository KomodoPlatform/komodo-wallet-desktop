import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

Widget
{
    title: qsTr("%1 Orderbook").arg(left_ticker + "/" + right_ticker)
    readonly property string pair_trades_24hr: API.app.trading_pg.pair_trades_24hr
    readonly property string pair_volume_24hr: API.app.trading_pg.pair_volume_24hr
    readonly property string pair: atomic_qt_utilities.retrieve_main_ticker(left_ticker) + "/" + atomic_qt_utilities.retrieve_main_ticker(right_ticker)

    margins: 8
    spacing: 8
    collapsable: false

    Header
    {
        Layout.preferredHeight: 30
        Layout.fillWidth: true
    }

    List
    {
        isAsk: true
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    Item
    {
        Layout.preferredHeight: 1
        Layout.fillWidth: true
        Rectangle
        {
            width: parent.width
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: Dex.CurrentTheme.backgroundColor
            opacity: 0.5
        }
    }

    List
    {
        isAsk: false
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    DexLabel
    {
        id: volume_text
        visible: parseFloat(pair_volume_24hr) > 0
        Layout.topMargin: 2
        Layout.bottomMargin: 2
        Layout.alignment: Qt.AlignHCenter
        color: Dex.CurrentTheme.foregroundColor2
        text_value: pair + qsTr(" 24hrs  |  %1  |  %2 trades").arg(General.convertUsd(pair_volume_24hr)).arg(pair_trades_24hr)
        font.pixelSize: Style.textSizeSmall1
    }
}
