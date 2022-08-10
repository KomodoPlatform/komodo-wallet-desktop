import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import App 1.0
import "../../../Components"
import Dex.Components 1.0 as Dex

RowLayout
{
    height: 24
    width: parent.width
    spacing: 0

    Dex.Text
    {
        Layout.preferredWidth: 140
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text_value: sell_mode ? qsTr("You get") : qsTr("You send")
        font.family: Style.font_family
        font.bold: true
        font.pixelSize: 12
        font.weight: Font.Black
    }

    Item { Layout.preferredWidth: (parent.width - 300) / 2 }

    Dex.Text
    {
        Layout.preferredWidth: 80
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text_value: qsTr("Fiat Price")
        font.family: Style.font_family
        font.bold: true
        font.pixelSize: 12
        font.weight: Font.Black
    }

    Item { Layout.preferredWidth: (parent.width - 300) / 2 }

    Dex.Text
    {
        Layout.preferredWidth: 80
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text_value: qsTr("CEX rate")
        font.family: Style.font_family
        font.bold: true
        font.pixelSize: 12
        font.weight: Font.Black
    }
}
