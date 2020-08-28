import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

Rectangle {
    width: 2

    gradient: Gradient {
        orientation: Qt.Horizontal
        GradientStop { position: 0.0; color: Style.colorLineGradient1 }
        GradientStop { position: 1.0; color: Style.colorLineGradient2 }
    }
}
