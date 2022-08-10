import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"
import Dex.Themes 1.0 as Dex
import App 1.0

BusyIndicator
{
    id: control
    property int indicatorSize: 64
    property int indicatorDotSize: 10

    contentItem: Item
    {
        implicitWidth: indicatorSize
        implicitHeight: indicatorSize

        Item
        {
            id: item
            x: (parent.width - indicatorSize) / 2
            y: (parent.height - indicatorSize) / 2
            width: indicatorSize
            height: indicatorSize
            opacity: control.running ? 1 : 0

            Behavior on opacity
            {
                OpacityAnimator
                {
                    duration: 250
                }
            }

            RotationAnimator
            {
                target: item
                running: control.visible && control.running
                from: 0
                to: 360
                loops: Animation.Infinite
                duration: 1250
            }

            Repeater
            {
                id: repeater
                model: 6

                Rectangle
                {
                    x: (item.width - width) / 2
                    y: (item.height - height) / 2
                    implicitWidth: indicatorDotSize
                    implicitHeight: indicatorDotSize
                    radius: indicatorDotSize / 2
                    color: Dex.CurrentTheme.busyIndicatorColor
                    transform: [
                        Translate
                        {
                            y: -Math.min(item.width, item.height) * 0.5 + indicatorDotSize / 2
                        },
                        Rotation
                        {
                            angle: index / repeater.count * 360
                            origin.x: indicatorDotSize / 2
                            origin.y: indicatorDotSize / 2
                        }
                    ]
                }
            }
        }
    }
}