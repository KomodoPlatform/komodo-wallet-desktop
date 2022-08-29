// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// Project Imports
import "../Constants" as Dex
import "../Components" as Dex
import App 1.0

RowLayout
{
    id: root
    property double   bar_width_pct: 0
    property color    bar_color: Dex.DexTheme.greenColor
    property alias    label: _label
    property alias    pct_bar: _pct_bar
    property alias    pct_value: _pct_value
    width: parent.width
    height: 42
    spacing: 5

    Dex.DexLabel
    {
        id: _label
        Layout.preferredWidth: 200
        font.bold: true
        Layout.alignment: Qt.AlignVCenter
        Component.onCompleted: font.weight = Font.Bold
    }

    // Progress bar
    Item
    {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        Layout.rightMargin: 10
        Layout.leftMargin: 10
        height: 5

        Rectangle
        {
            id: bg_bar
            anchors.fill: parent
            radius: 5
            opacity: 0.1
            color: DexTheme.foregroundColorLightColor5
        }

        Rectangle
        {
            id: _pct_bar
            height: parent.height
            radius: 5
            width: bar_width_pct / 100 * parent.width 
            color: root.bar_color
        }
    }

    Dex.DexLabel
    {
        id: _pct_value
        Layout.preferredWidth: 60
        text: "0.00 %"
        Layout.alignment: Qt.AlignVCenter
        Component.onCompleted: font.family = 'lato'
    }
}
