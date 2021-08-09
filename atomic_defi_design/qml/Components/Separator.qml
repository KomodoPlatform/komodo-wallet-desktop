import QtQuick 2.15
import "../Constants"
import App 1.0

Rectangle {
    height: 1
    width: 150

    gradient: Gradient {
        orientation: Qt.Horizontal

        GradientStop { position: 0.0; color: Style.colorGradientLine1 }
        GradientStop { position: 0.5; color: Style.colorGradientLine2 }
        GradientStop { position: 1.0; color: Style.colorGradientLine1 }
    }
}
