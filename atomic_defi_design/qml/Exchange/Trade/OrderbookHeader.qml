import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"

Item {
    property bool is_ask: false
    property bool is_horizontal: false
    height: 40
    width: parent.width
    z: 2
    Rectangle {
        anchors.fill: parent
        color: Style.colorTheme9
    }

    RowLayout {
        width: parent.width - 30
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 80
            text: is_ask? qsTr("Price") + " ("+right_ticker+")" : qsTr("Price") + " ("+right_ticker+")"
            font.family: Style.font_family
            font.pixelSize: 10
            font.bold: true
            color: is_ask? "#E31A93" : Style.colorGreen
            font.weight: Font.Black
        }
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 90

            text: qsTr("Quantity") + " ("+left_ticker+")"
            font.family: Style.font_family
            font.pixelSize: 10
            font.bold: true
            font.weight: Font.Black
            horizontalAlignment: Label.AlignRight

        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 120
            text: qsTr("Total") + "("+right_ticker+")"
            horizontalAlignment: Label.AlignRight
            font.family: Style.font_family
            font.pixelSize: 10
            font.bold: true
            font.weight: Font.Black
        }
    }

}
