import QtQuick 2.15
import "../Constants"
import App 1.0

AnimatedRectangle {
    height: 2
    property bool light: false

    gradient: Gradient {
        orientation: Qt.Vertical
        GradientStop { position: 0.0; color: light ? DexTheme.colorLineGradient3 : DexTheme.colorLineGradient2 }
        GradientStop { position: 1.0; color: light ? DexTheme.colorLineGradient4 : DexTheme.colorLineGradient1 }
    }
}
