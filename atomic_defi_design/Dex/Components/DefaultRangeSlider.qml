import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtWebEngine 1.8

import Qaterial 1.0 as Qaterial

import "../Exchange/Trade/"
import "../Constants/" as Constants
import Dex.Themes 1.0 as Dex

RangeSlider
{
    id: control

    property color rangeDistanceColor: Dex.CurrentTheme.rangeSliderDistanceColor
    property color rangeBackgroundColor: Dex.CurrentTheme.rangeSliderBackgroundColor
    property bool  firstDisabled: true
    property var   firstSavedValue: first.value

    property alias leftText: _left_item.text
    property alias rightText: _right_item.text

    opacity: enabled ? 1 : .5
    first.value: 0.25
    second.value: .75

    background: Rectangle
    {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: control.rangeDistanceColor

        Rectangle
        {
            x: control.first.visualPosition * parent.width
            width: control.second.visualPosition * parent.width - x
            height: parent.height
            color: control.rangeBackgroundColor
            radius: 2
        }
    }

    first.handle: Rectangle
    {
        x: control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 18
        implicitHeight: 18
        radius: 9
        visible: !firstDisabled
        enabled: visible
        gradient: Gradient
        {
            orientation: Qt.Horizontal
            GradientStop
            {
                color: Dex.CurrentTheme.rangeSliderIndicatorBackgroundStartColor
                position: 0
            }
            GradientStop
            {
                color: Dex.CurrentTheme.rangeSliderIndicatorBackgroundEndColor
                position: 0.6
            }
        }
    }
    first.onValueChanged:
    {
        if (firstDisabled) first.value = firstSavedValue;
        else firstSavedValue = first.value
    }

    second.handle: Rectangle
    {
        x: control.leftPadding + control.second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 18
        implicitHeight: 18
        radius: 9
        gradient: Gradient
        {
            orientation: Qt.Horizontal
            GradientStop
            {
                color: Dex.CurrentTheme.rangeSliderIndicatorBackgroundStartColor
                position: 0
            }
            GradientStop
            {
                color: Dex.CurrentTheme.rangeSliderIndicatorBackgroundEndColor
                position: 0.6
            }
        }
    }

    DexLabel
    {
        id: _left_item
        anchors.left: parent.left
        anchors.top: parent.bottom
        text_value: qsTr("Min")
    }

    DexLabel
    {
        id: _right_item
        anchors.right: parent.right
        anchors.top: parent.bottom
        text_value: qsTr("Max")
    }
}
