import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

Item
{
    id: orderBook
    visible: isUltraLarge

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 10

        FloatingBackground
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 2
            ColumnLayout
            {
                anchors.fill: parent
                spacing: 2
                List
                {
                    isAsk: true
                    isVertical: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                Item
                {
                    Layout.preferredHeight: 4
                    Layout.fillWidth: true
                    Rectangle
                    {
                        width: parent.width
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Dex.CurrentTheme.floatingBackgroundColor
                    }
                }
                List
                {
                    isAsk: false
                    hide_header: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }
}
