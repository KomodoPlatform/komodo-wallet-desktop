import QtQuick 2.15
import Qaterial 1.0 as Qaterial

DexRectangle {
    id: control 
    signal clicked()
    property int padding: 10
    property string text: ""
    property string iconSource: ""
    property int spacing: 4
    property string backgroundColor: theme.buttonColorEnabled
    //property var alignment: Qt.AlignCenter
    property var verticalAlignment: Qt.AlignVCenter
    property var horizontalAlignment: Qt.AlignHCenter
    property alias padding: _contentRow.padding
    property alias leftPadding: _contentRow.leftPadding
    property alias rightPadding: _contentRow.rightPadding
    property alias topPadding: _contentRow.topPadding
    property alias bottomPadding: _contentRow.bottomPadding
    property alias label: _label
    radius: 4 
    color: _controlMouseArea.containsMouse? Qt.darker(backgroundColor, 0.8) : backgroundColor
    height: _label.implicitHeight+(padding*2)
    width: _label.implicitWidth+(padding*2)
    Row {
        id: _contentRow
        anchors {
            //centerIn: parent.alignment == Qt.AlignCenter? parent : undefined 
            right: parent.horizontalAlignment == Qt.AlignRight? parent.right : undefined
            left: parent.horizontalAlignment == Qt.AlignLeft? parent.left : undefined
            horizontalCenter: parent.horizontalAlignment == Qt.AlignHCenter ? parent.horizontalCenter : undefined
            verticalCenter: parent.verticalAlignment == Qt.AlignVCenter ? parent.verticalCenter :  undefined
        }
        spacing: parent.spacing
        Qaterial.ColorIcon {
            id: _icon 
            anchors.verticalCenter: parent.verticalCenter
            iconSize: _label.font.pixelSize+2
            source: control.iconSource
        }
        DexLabel {
            id: _label
            anchors.verticalCenter: parent.verticalCenter
            font: _font.button
            text: control.text
        }
    }
    DexMouseArea {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true 
        onClicked: control.clicked()
    }
}