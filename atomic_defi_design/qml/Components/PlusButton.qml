import QtQuick 2.15
import "../Constants"
import App 1.0

// Add button
DefaultButton {
    width: 45
    height: width

    text: "+"
    font.pixelSize: width * 0.65
    font.weight: Font.Normal

    verticalShadow: true
}
