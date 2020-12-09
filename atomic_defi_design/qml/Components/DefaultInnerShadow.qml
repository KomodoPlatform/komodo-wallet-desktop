import QtGraphicalEffects 1.0
import "../Constants/Style.qml" as Style

InnerShadow {
    cached: false
    horizontalOffset: 0.7
    verticalOffset: 0.7
    radius: 13
    samples: 32
    color: Style.colorInnerShadow
    smooth: true
}
