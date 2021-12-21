import QtQuick 2.15

import "../Constants"
import "../Components"
import Dex.Themes 1.0 as Dex

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
        color: up ? Dex.CurrentTheme.arrowUpColor : Dex.CurrentTheme.arrowDownColor
    }
}

