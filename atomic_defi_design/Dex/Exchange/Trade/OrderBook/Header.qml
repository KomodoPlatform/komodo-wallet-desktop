import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

Item
{
    property bool is_ask: false
    property bool is_horizontal: false

    RowLayout
    {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        DefaultText
        {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            text: is_ask ?
                      qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")" :
                      qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
        }
        DefaultText
        {
            Layout.alignment: Qt.AlignCenter

            text: qsTr("Quantity") + " ("+  atomic_qt_utilities.retrieve_main_ticker(left_ticker) +")"
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black

        }
        DefaultText
        {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            text: qsTr("Total") + "(" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
            font.family: DexTypo.fontFamily
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
        }
    }

}
