import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../Constants"

Item {
    property bool up: true
    property alias color: img_overlay.color

    width: img.width
    height: img.height

    Image {
        id: img

        source: General.image_path + "arrow_" + (up ? "up" : "down") + ".svg"

        width: 10;
        fillMode: Image.PreserveAspectFit

        visible: false
    }

    ColorOverlay {
        id: img_overlay

        anchors.fill: img
        source: img
        color: Style.colorWhite1
    }
}

