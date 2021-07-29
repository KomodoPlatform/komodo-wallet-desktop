import QtQuick 2.15
import App 1.0

AnimatedRectangle {
    id: rect
    property bool sizeAnimation: false
    property int sizeAnimationDuration: 150
    radius: DexTheme.rectangleRadius
    color: DexTheme.backgroundColor
    border.color: DexTheme.rectangleBorderColor
    border.width: 1

    Behavior on width {
        enabled: rect.sizeAnimation
        NumberAnimation {
            duration: rect.sizeAnimationDuration
        }
    }
    Behavior on height {
        enabled: rect.sizeAnimation
        NumberAnimation {
            duration: rect.sizeAnimationDuration
        }
    }
}