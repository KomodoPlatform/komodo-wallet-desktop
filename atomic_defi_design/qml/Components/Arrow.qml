import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import "../Constants"

Item {
    property bool up: true
    property alias color: img_overlay.color

    width: img.width
    height: img.height

    DefaultImage {
        id: img

        source: General.image_path + "arrow_" + (up ? "up" : "down") + ".svg"

        width: 10;

        visible: false
    }

    DefaultColorOverlay {
        id: img_overlay

        anchors.fill: img
        source: img
        color: Style.colorWhite1
    }
}

