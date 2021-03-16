import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0


import QtQuick.Window 2.12

import Qaterial 1.0 as Qaterial

Item {
    property bool selected: false
    property alias text: _label.text
    property alias hovered: area.containsMouse
    signal clicked()
    width: parent.width-20
    anchors.horizontalCenter: parent.horizontalCenter
    height: 45
    Rectangle {
        anchors.fill: parent
        height: 45
        radius: 5
        opacity: parent.hovered? .4 : !parent.selected? 0 : .9
        color: theme.hightlightColor
    }
    DexLabel {
        id: _label
        anchors.centerIn: parent
        font: theme.textType.button
        text: ""
        opacity: area.containsMouse? 1 : .7
    }
    MouseArea {
        id: area
        cursorShape: "PointingHandCursor"
        onClicked: parent.clicked()
        anchors.fill: parent
    }
}
