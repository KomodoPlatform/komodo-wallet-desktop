import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0

import "../../../Components"

Item
{
    property bool is_ask: false
    RowLayout
    {
        anchors.fill: parent
        DefaultText
        {
            Layout.preferredWidth: (parent.width / 100) * 33
            text: is_ask ? qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")" :
                           qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
            horizontalAlignment: Text.AlignRight
        }
        DefaultText
        {
            Layout.preferredWidth: (parent.width / 100) * 30
            text: qsTr("Quantity") + " (" +  atomic_qt_utilities.retrieve_main_ticker(left_ticker) + ")"
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
            horizontalAlignment: Text.AlignRight
        }
        DefaultText
        {
            Layout.preferredWidth: (parent.width / 100) * 30
            text: qsTr("Total") + " (" +  atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
            horizontalAlignment: Text.AlignRight
        }
    }
}
