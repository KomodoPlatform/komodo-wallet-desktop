import QtQuick 2.15
import QtGraphicalEffects 1.0
import "../Constants"

ColorOverlay {
    Behavior on color { ColorAnimation { duration: Style.animationDuration } }
}
