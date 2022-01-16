//! Qt Imports.
import QtQuick 2.15

//! 3rdParty Imports.
import Qaterial 1.0 as Qaterial

//! Project Imports.
import App 1.0
import Dex.Themes 1.0 as Dex

Item
{
    id: control

    property int    padding: 10
    property string icon: Qaterial.Icons.bellOutline
    property alias  color: _label.color
    property alias  iconSize: _label.size
    property alias  containsMouse: _controlMouseArea.containsMouse
    property bool   active: false

    signal clicked()

    height: 20
    width: 20

    Qaterial.Icon
    {
        id: _label
        anchors.centerIn: parent
        icon: parent.icon
        color: Dex.CurrentTheme.foregroundColor
        opacity: _controlMouseArea.containsMouse ? 1 : .7
    }

    DexMouseArea
    {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }
}
