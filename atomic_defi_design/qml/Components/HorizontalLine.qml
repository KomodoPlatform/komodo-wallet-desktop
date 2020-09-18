import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

AnimatedRectangle {
    height: 2
    property bool light: false

    gradient: Gradient {
        orientation: Qt.Vertical
        GradientStop { position: 0.0; color: light ? Style.colorLineGradient3 : Style.colorLineGradient2 }
        GradientStop { position: 1.0; color: light ? Style.colorLineGradient4 : Style.colorLineGradient1 }
    }
}
