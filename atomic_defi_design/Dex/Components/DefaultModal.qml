import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Constants"
import App 1.0

Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Overlay.modal: Rectangle {
        color: "#AA000000"
    }

    // Fade in animation
    onVisibleChanged: {
        if(visible) {
            opacity = 0
            fade_animation.start()
        }
    }

    NumberAnimation {
        id: fade_animation
        target: root
        property: "opacity"
        duration: Style.animationDuration
        to: 1
    }

    background: DexRectangle { }
}
