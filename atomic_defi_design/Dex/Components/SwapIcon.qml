import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

Item
{
    id: root

    property string top_arrow_ticker
    property string bottom_arrow_ticker
    property bool   hovered: false
    property color  color: Dex.CurrentTheme.foregroundColor

    implicitWidth: 20
    implicitHeight: 50

    Qaterial.ColorIcon
    {
        anchors.centerIn: parent
        source: Qaterial.Icons.swapHorizontal
        color: root.color
    }
}
