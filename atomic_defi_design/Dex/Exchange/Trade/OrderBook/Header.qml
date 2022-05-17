import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

RowLayout
{
    width: parent.width
    height: 24
    spacing: 0

    DexLabel
    {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: 100
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: qsTr("Price") + " (" + atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }

    Item { Layout.preferredWidth: (parent.width - 300) / 2 }

    DexLabel
    {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: 120
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: qsTr("Quantity") + " (" +  atomic_qt_utilities.retrieve_main_ticker(left_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }

    Item { Layout.preferredWidth: (parent.width - 300) / 2 }

    DexLabel
    {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: 80
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: qsTr("Total") + " (" +  atomic_qt_utilities.retrieve_main_ticker(right_ticker) + ")"
        font.family: DexTypo.fontFamily
        font.pixelSize: 12
        font.bold: true
        font.weight: Font.Black
    }
}