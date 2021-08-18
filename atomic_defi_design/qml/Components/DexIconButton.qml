import QtQuick 2.15
import Qaterial 1.0 as Qaterial

Item {
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
        color: parent.color
    }

    DexMouseArea
    {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }
}
