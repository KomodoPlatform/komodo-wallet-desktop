import QtQuick 2.12

import Dex.Components 1.0 as Dex
import "../Constants" as Dex

Row
{
    property string ticker
    property string name
    property string type

    spacing: 10

    Dex.Image
    {
        width: 25
        height: 25
        anchors.verticalCenter: parent.verticalCenter
        source: Dex.General.coinIcon(ticker)
    }

    Dex.Text
    {
        anchors.verticalCenter: parent.verticalCenter
        text: name
    }

    Dex.Text
    {
        anchors.verticalCenter: parent.verticalCenter
        text: type
        color: Dex.Style.getCoinTypeColor(type)
        font: Dex.DexTypo.overLine
    }
}
