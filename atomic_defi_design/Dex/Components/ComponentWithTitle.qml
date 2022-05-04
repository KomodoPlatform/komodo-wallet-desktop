import QtQuick 2.15
import QtQuick.Layouts 1.15

import App 1.0
import "../Constants"
import Dex.Themes 1.0 as Dex

ColumnLayout
{
    property alias          title: title.text
    property alias          title_font: title.font
    property bool           expandable: false
    property bool           expanded: false
    readonly property bool  show_content: !expandable || expanded

    RowLayout
    {
        id: rowLayout
        Layout.fillWidth: true

        Arrow
        {
            id: arrowIco

            visible: expandable

            Layout.alignment: Qt.AlignVCenter

            up: expanded
            color: mouseArea.containsMouse ? Dex.CurrentTheme.foregroundColor3 : Dex.CurrentTheme.foregroundColor2
        }

        TitleText
        {
            id: title
            Layout.fillWidth: true

            color: Dex.CurrentTheme.foregroundColor2

            DefaultMouseArea
            {
                id: mouseArea
                enabled: expandable
                anchors.fill: parent
                anchors.leftMargin: -arrowIco.width - rowLayout.spacing
                hoverEnabled: true
                onClicked: expanded = !expanded
            }
        }
    }
}
