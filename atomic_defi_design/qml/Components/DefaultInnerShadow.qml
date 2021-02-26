import QtQuick 2.15
import QtGraphicalEffects 1.0
import "../Constants"

InnerShadow {
    cached: false
    horizontalOffset: 0.7
    verticalOffset: 0.7
    radius: 13
    samples: 32
    color: Style.colorInnerShadow
    smooth: true
}
