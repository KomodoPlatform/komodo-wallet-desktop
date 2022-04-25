import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

Row
{
    DexLabel
    {
        width: parent.width * price_col_width
        horizontalAlignment: Text.AlignLeft
        text: qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }
    DexLabel
    {
        width: parent.width * qty_col_width
        horizontalAlignment: Text.AlignRight
        text: qsTr("Quantity") + " (" +  atomic_qt_utilities.retrieve_main_ticker(left_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }
    DexLabel
    {
        width: parent.width * total_col_width
        horizontalAlignment: Text.AlignRight
        text: qsTr("Total") + " (" +  atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }
}
