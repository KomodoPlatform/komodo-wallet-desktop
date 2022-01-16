import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

FloatingBackground
{
    visible: isUltraLarge
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 10

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Header
        {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
        }

        List
        {
            isAsk: true
            isVertical: true
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Item
        {
            Layout.preferredHeight: 8
            Layout.fillWidth: true
        }

        List
        {
            isAsk: false
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
