import QtQuick 2.15
DexRectangle {
    id: control 
    signal clicked()
    property int padding: 10
    property string text: ""
    radius: 4 
    property string backgroundColor: theme.buttonColorEnabled
    color: _controlMouseArea.containsMouse? Qt.darker(backgroundColor, 0.8) : backgroundColor
    height: _label.implicitHeight+(padding*2)
    width: _label.implicitWidth+(padding*2)
    DexLabel {
        id: _label
        anchors.centerIn: parent
        font: _font.button
        text: parent.text
    }
    DexMouseArea {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true 
        onClicked: control.clicked()
    }
}