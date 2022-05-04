import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"
import Dex.Themes 1.0 as Dex
import App 1.0

BusyIndicator
{
    id: control
    property int indicator_size: 64
    property int indicator_dot_size: 10

    contentItem: Item
    {
        implicitWidth: indicator_size
        implicitHeight: indicator_size

        Item
        {
            id: item
            x: (parent.width - indicator_size) / 2
            y: (parent.height - indicator_size) / 2
            width: indicator_size
            height: indicator_size
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
                    implicitWidth: indicator_dot_size
                    implicitHeight: indicator_dot_size
                    radius: indicator_dot_size / 2
                    color: Dex.CurrentTheme.busyIndicatorColor
                    transform: [
                        Translate
                        {
                            y: -Math.min(item.width, item.height) * 0.5 + indicator_dot_size / 2
                        },
                        Rotation
                        {
                            angle: index / repeater.count * 360
                            origin.x: indicator_dot_size / 2
                            origin.y: indicator_dot_size / 2
                        }
                    ]
                }
            }
        }
    }
}