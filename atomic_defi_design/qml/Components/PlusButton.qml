import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

// Add button
DefaultButton {
    width: 45
    height: width
    radius: 100

    text: "+"
    font.pixelSize: width * 0.65
    font.weight: Font.Light

    verticalShadow: true

    colorEnabled: Style.colorButtonHovered[button_type]
    colorHovered: Style.colorButtonEnabled[button_type]
}
