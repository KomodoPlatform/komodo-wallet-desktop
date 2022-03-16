import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0

import "../../../Components"

Row
{
    spacing: 0

    DefaultText
    {
        width: parent.width * youGetColumnWidth
        text: sell_mode ? qsTr("You get") : qsTr("You send")
        font.family: Style.font_family
        font.pixelSize: 12
        font.weight: Font.Black
    }
    DefaultText
    {
        width: parent.width * fiatPriceColumnWidth
        text: qsTr("Fiat Price")
        font.family: Style.font_family
        font.pixelSize: 12
        font.weight: Font.Black

    }
    DefaultText
    {
        width: parent.width * cexRateColumnWidth
        Layout.alignment: Qt.AlignVCenter
        text: qsTr("CEX rate")
        font.family: Style.font_family
        font.pixelSize: 12
        font.weight: Font.Black
    }
}
