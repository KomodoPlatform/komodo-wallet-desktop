import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0

import "../../../Components"

Item {
    property bool is_horizontal: false
    height: 40
    width: parent.width
    z: 2

    RowLayout
    {
        width: parent.width - 30
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        DefaultText
        {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 130
            text: sell_mode? qsTr("You get") : qsTr("You send")
            font.family: Style.font_family
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
        }
        DefaultText
        {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 70

            text: qsTr("Fiat Price")
            font.family: Style.font_family
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
            horizontalAlignment: Label.AlignRight

        }
        DefaultText
        {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("CEX rate")
            horizontalAlignment: Label.AlignRight
            font.family: Style.font_family
            font.pixelSize: 12
            font.bold: true
            font.weight: Font.Black
        }
    }

}
