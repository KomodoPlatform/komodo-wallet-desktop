import QtQuick 2.15
import Qaterial 1.0 as Qaterial

Item {
    id: control 
    signal clicked()
    
    property int padding: 10
    property string icon: Qaterial.Icons.bellOutline
    property alias color:_label.color 
    property alias iconSize: _label.iconSize
    property alias containsMouse: _controlMouseArea.containsMouse
    property bool active: false

    height: _label.implicitHeight+(padding*2)
    width: _label.implicitWidth+(padding*2)
    Qaterial.ColorIcon {
        id: _label
        anchors.centerIn: parent
        source: parent.icon
        color: parent.color
    }
    DexMouseArea {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true 
        onClicked: control.clicked()
    }
}