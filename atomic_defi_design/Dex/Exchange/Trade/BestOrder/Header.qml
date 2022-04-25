import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0

import "../../../Components"

Row
{
    DexLabel
    {
        width: parent.width * youGetColumnWidth
        horizontalAlignment: Text.AlignLeft
        text_value: sell_mode ? qsTr("You get") : qsTr("You send")
        font.family: Style.font_family
        font.bold: true
        font.pixelSize: 12
        font.weight: Font.Black
    }

    DexLabel
    {
        width: parent.width * fiatPriceColumnWidth
        horizontalAlignment: Text.AlignRight
        text_value: qsTr("Fiat Price")
        font.family: Style.font_family
        font.bold: true
        font.pixelSize: 12
        font.weight: Font.Black

    }

    DexLabel
    {
        width: parent.width * cexRateColumnWidth
        horizontalAlignment: Text.AlignRight
        text_value: qsTr("CEX rate")
        font.family: Style.font_family
        font.bold: true
        font.pixelSize: 12
        font.weight: Font.Black
    }
}