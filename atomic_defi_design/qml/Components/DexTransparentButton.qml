import QtQuick 2.15
import Qaterial 1.0 as Qaterial

import App 1.0 

DexAppButton {
    id: control
    text: control.buttonText
    color: containsMouse ? DexTheme.buttonColorHovered : 'transparent'
    height: 48
    radius: 20
    font: Qt.font({
        pixelSize: 14,
        letterSpacing: 0.15,
        family: DexTypo.fontFamily,
        underline: true,
        weight: Font.Normal
    })
}