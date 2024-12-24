import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtWebEngine 1.8
import "../Exchange/Trade/"
import "../Constants/"
as Constants

RangeSlider {
    id: control


    opacity: enabled ? 1 : .5
    first.value: 0.25
    second.value: .75
    property color rangeDistanceColor: Constants.Style.colorGreen
    property color rangeBackgroundColor: Constants.Style.colorTheme9
    property bool firstDisabled: false
    property
    var defaultFirstValue: 0.0

    property alias leftText: _left_item.text
    property alias halfText: _half_item.text
    property alias rightText: _right_item.text

    property alias firstTooltip: firstTooltip
    property alias secondTooltip: secondTooltip
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: control.rangeBackgroundColor

        Rectangle {
            x: control.first.visualPosition * parent.width
            width: control.second.visualPosition * parent.width - x
            height: parent.height
            color: control.rangeDistanceColor
            radius: 2
        }
    }
    first.onValueChanged: {
        if (firstDisabled) {
            first.value = defaultFirstValue
        }
    }
    first.handle: FloatingBackground {
        x: control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        visible: !control.firstDisabled
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 10
            color: control.rangeDistanceColor
        }

        //border.color: "#bdbebf"
    }
    second.handle: FloatingBackground {
        x: control.leftPadding + control.second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 10
            color: control.rangeDistanceColor
        }

        //border.color: "#bdbebf"
    }

    DexLabel {
        id: secondTooltip
        visible: parent.second.pressed
        anchors.horizontalCenter: parent.second.handle.horizontalCenter
        anchors.bottom: parent.second.handle.top

        text_value: parent.second.value
        font.pixelSize: Constants.Style.textSizeSmall1
    }
    DexLabel {
        id: firstTooltip
        visible: parent.first.pressed
        anchors.horizontalCenter: parent.first.handle.horizontalCenter
        anchors.bottom: parent.first.handle.top

        text_value: parent.first.value
        font.pixelSize: Constants.Style.textSizeSmall1
    }
    DexLabel {
        id: _left_item
        anchors.left: parent.left
        anchors.top: parent.bottom

        text_value: qsTr("Min")
    }
    DexLabel {
        id: _half_item
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom

        text_value: qsTr("Half")
    }
    DexLabel {
        id: _right_item
        anchors.right: parent.right
        anchors.top: parent.bottom

        text_value: qsTr("Max")
    }
}