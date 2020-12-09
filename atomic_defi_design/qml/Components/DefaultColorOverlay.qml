import QtQuick 2.15
import QtGraphicalEffects 1.0
import "../Constants/Style.qml" as Style

ColorOverlay {
    Behavior on color { ColorAnimation { duration: Style.animationDuration } }
}
