import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

Row
{
    DefaultText
    {
        width: (parent.width / 100) * 34
        text: qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
        horizontalAlignment: Text.AlignRight
    }
    DefaultText
    {
        width: (parent.width / 100) * 32
        text: qsTr("Quantity") + " (" +  atomic_qt_utilities.retrieve_main_ticker(left_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
        horizontalAlignment: Text.AlignRight
    }
    DefaultText
    {
        width: (parent.width / 100) * 32
        text: qsTr("Total") + " (" +  atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
        horizontalAlignment: Text.AlignRight
    }
}
