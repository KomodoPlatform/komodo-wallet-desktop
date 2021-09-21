import QtQuick 2.15
import QtGraphicalEffects 1.0
import "../Constants"
import App 1.0

ColorOverlay {
    Behavior on color { ColorAnimation { duration: Style.animationDuration } }
}
