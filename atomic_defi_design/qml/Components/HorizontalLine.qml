import QtQuick 2.15
import "../Constants"

AnimatedRectangle {
    height: 2
    property bool light: false

    gradient: Gradient {
        orientation: Qt.Vertical
        GradientStop { position: 0.0; color: light ? theme.colorLineGradient3 : theme.colorLineGradient2 }
        GradientStop { position: 1.0; color: light ? theme.colorLineGradient4 : theme.colorLineGradient1 }
    }
}
