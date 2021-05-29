import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

Item {
    property bool is_ask: false
    property bool is_horizontal: false
    height: 40
    width: parent.width
    z: 2
    Rectangle {
        anchors.fill: parent
        color: theme.dexBoxBackgroundColor
    }

    RowLayout {
        width: parent.width - 30
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 60
            text: is_ask? qsTr("Price") + " ("+atomic_qt_utilities.retrieve_main_ticker(right_ticker)+")" : qsTr("Price") + " ("+atomic_qt_utilities.retrieve_main_ticker(right_ticker)+")"
            font.family: _font.fontFamily
            font.pixelSize: 9
            font.bold: true
            font.weight: Font.Black
            color: is_ask? theme.redColor : theme.greenColor
        }
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 100

            text: qsTr("Quantity") + " ("+  atomic_qt_utilities.retrieve_main_ticker(left_ticker) +")"
            font.family: _font.fontFamily
            font.pixelSize: 9
            font.bold: true
            font.weight: Font.Black
            horizontalAlignment: Label.AlignRight

        }
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            text: qsTr("Total") + "("+  atomic_qt_utilities.retrieve_main_ticker(right_ticker) +")"
            horizontalAlignment: Label.AlignRight
            font.family: _font.fontFamily
            font.pixelSize: 9
            font.bold: true
            font.weight: Font.Black
        }
    }

}
