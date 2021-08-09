import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

import App 1.0

import QtQuick.Window 2.12

import Qaterial 1.0 as Qaterial

Item {
    property bool selected: false
    property alias text: _label.text
    property alias hovered: area.containsMouse
    property bool outlined: false
    
    anchors.horizontalCenter: parent.horizontalCenter
    
    width: parent.width - 20
    height: 45
    
    signal clicked()

    DexRectangle {
        anchors.fill: parent
        height: 45
        radius: 5
        opacity: parent.hovered ? .6 : !parent.selected ? 0 : .9
        color: outlined ? 'transparent' : DexTheme.accentColor
        border.color: outlined ? DexTheme.accentColor : 'transparent' 
    }

    DexLabel {
        id: _label
        anchors.centerIn: parent
        font: DexTypo.button
        color: DexTheme.foregroundColor
        text: ""
        opacity: area.containsMouse ? 1 : .7
    }

    DexMouseArea {
        id: area
        hoverEnabled: true
        onClicked: parent.clicked()
        anchors.fill: parent
    }
}