import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0

import "../../../Components"

RowLayout
{
    id: columnsHeader
    width: youGetColumnWidth + fiatPriceColumnWidth + cexRateColumnWidth
    height: 36

    spacing: 0

    DefaultText
    {
        Layout.preferredWidth: youGetColumnWidth
        horizontalAlignment: Text.AlignLeft
        text: sell_mode ? qsTr("You get") : qsTr("You send")
        font.family: Style.font_family
        font.pixelSize: 12
        font.weight: Font.Black
    }
    DefaultText
    {
        Layout.preferredWidth: fiatPriceColumnWidth
        width: fiatPriceColumnWidth
        horizontalAlignment: Text.AlignRight
        text: qsTr("Fiat Price")
        font.family: Style.font_family
        font.pixelSize: 12
        font.weight: Font.Black

    }
    DefaultText
    {
        Layout.preferredWidth: cexRateColumnWidth
        width: cexRateColumnWidth
        horizontalAlignment: Text.AlignRight
        text: qsTr("CEX rate")
        font.family: Style.font_family
        font.pixelSize: 12
        font.weight: Font.Black
    }
}