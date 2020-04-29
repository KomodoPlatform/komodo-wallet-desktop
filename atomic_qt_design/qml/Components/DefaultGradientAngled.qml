import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "../Constants"

// Gradient
LinearGradient {
    anchors.fill: parent
    source: parent
    start: Qt.point(0, 0)
    end: Qt.point(parent.width, parent.height)
    gradient: Gradient {
        GradientStop { position: 0.0; color: Style.colorGradient3 }
        GradientStop { position: 1.0; color: Style.colorGradient4 }
    }
}
