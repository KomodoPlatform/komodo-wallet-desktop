// Qt Imports
import QtQuick 2.15

// Project Imports
import "../Constants"           //> General.image_path
import Dex.Themes 1.0 as Dex    //> CurrentTheme

Item {
    property bool   up: true
    property alias  color: imgOverlay.color

    width: img.width
    height: img.height

    DefaultImage
    {
        id: img

        width: 18
        height: 10
        visible: false
        source: General.image_path + "arrow_" + (up ? "up" : "down") + ".svg"
    }

    DefaultColorOverlay
    {
        id: imgOverlay

        anchors.fill: img
        source: img
        color: Dex.CurrentTheme.foregroundColor
    }
}

