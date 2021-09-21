import QtQuick 2.15
import "../Constants"
import App 1.0

AnimatedRectangle {
    width: 2

    gradient: Gradient {
        orientation: Qt.Horizontal
        GradientStop { position: 0.0; color: Style.colorLineGradient1 }
        GradientStop { position: 1.0; color: Style.colorLineGradient2 }
    }
}
