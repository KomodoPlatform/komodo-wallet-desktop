import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import App 1.0

DexRectangle {
    id: control 
    signal clicked()

    property int padding: 10
    property int spacing: 4
    property int verticalAlignment: Qt.AlignVCenter
    property int horizontalAlignment: Qt.AlignHCenter

    property alias label: _label
    property alias font: _label.font
    property alias leftPadding: _contentRow.leftPadding
    property alias rightPadding: _contentRow.rightPadding
    property alias topPadding: _contentRow.topPadding
    property alias bottomPadding: _contentRow.bottomPadding

    property string text: ""
    property string iconSource: ""
    property string backgroundColor: enabled? _controlMouseArea.containsMouse? DexTheme.buttonColorHovered : DexTheme.buttonColorEnabled : DexTheme.buttonColorDisabled

    radius: 4 
    color: _controlMouseArea.containsMouse ? Qt.darker(backgroundColor, 0.8) : backgroundColor
    height: _label.implicitHeight + (padding * 2)
    width: _contentRow.width + (padding * 2)
    Row {
        id: _contentRow
        anchors {
            horizontalCenter: parent.horizontalAlignment == Qt.AlignHCenter ? parent.horizontalCenter : undefined
            verticalCenter: parent.verticalAlignment == Qt.AlignVCenter ? parent.verticalCenter :  undefined
        }
        spacing: _icon.visible ? parent.spacing : 0
        Qaterial.ColorIcon {
            id: _icon
            iconSize: _label.font.pixelSize + 2
            visible: control.iconSource === "" ? false : true 
            source: control.iconSource
            color: _label.color
            anchors.verticalCenter: parent.verticalCenter
        }
        DexLabel {
            id: _label
            anchors.verticalCenter: parent.verticalCenter
            font: DexTypo.button
            text: control.text
            color: control.enabled? _controlMouseArea.containsMouse? DexTheme.buttonColorTextHovered : DexTheme.buttonColorTextEnabled : DexTheme.buttonColorTextDisabled
        }
    }
    DexMouseArea {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true 
        onClicked: control.clicked()
    }
}