import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Constants"

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
