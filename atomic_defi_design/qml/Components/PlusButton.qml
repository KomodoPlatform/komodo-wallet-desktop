import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Constants"

// Add button
DefaultButton {
    width: 45
    height: width

    text: "+"
    font.pixelSize: width * 0.65
    font.weight: Font.Normal

    verticalShadow: true

    colorEnabled: Style.colorButtonHovered[button_type]
    colorHovered: Style.colorButtonEnabled[button_type]
}
