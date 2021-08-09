import QtQuick 2.15
import QtGraphicalEffects 1.0
import "../Constants"
import App 1.0

InnerShadow {
    cached: false
    horizontalOffset: 0.7
    verticalOffset: 0.7
    radius: 13
    samples: 32
    color: DexTheme.innerShadowColor
    smooth: true
}