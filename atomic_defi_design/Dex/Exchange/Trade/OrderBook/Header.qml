import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Constants"
import Dex.Components 1.0 as Dex

Row
{
    width: parent.width
    height: 24
    spacing: 0

    Dex.Text
    {
        width: parent.width * 0.31
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }

    Item { width: parent.width * 0.01 }

    Dex.Text
    {
        width: parent.width * 0.37
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: qsTr("Quantity") + " (" +  atomic_qt_utilities.retrieve_main_ticker(left_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }

    Item { width: parent.width * 0.01 }

    Dex.Text
    {
        width: parent.width * 0.30
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: qsTr("Total") + " (" +  atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }
}
