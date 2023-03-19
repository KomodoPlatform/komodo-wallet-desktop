import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

Slider
{
    id: control
    value: 0.5
    opacity: enabled ? 1 : .5

    background: Rectangle
    {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: Dex.CurrentTheme.rangeSliderDistanceColor

        Rectangle
        {
            width: control.visualPosition * parent.width
            height: parent.height
            color: Dex.CurrentTheme.rangeSliderBackgroundColor
            radius: 2
        }
    }

    handle: Rectangle
    {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 18
        implicitHeight: 18
        radius: 13
        gradient: Gradient
        {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.125; color: Dex.CurrentTheme.rangeSliderIndicatorBackgroundStartColor }
            GradientStop { position: 0.925; color: Dex.CurrentTheme.rangeSliderIndicatorBackgroundEndColor }
        }
    }
}
