import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0

import "../Constants"

AnimatedRectangle {
    id: rect
    radius: Style.rectangleCornerRadius
    color: Style.colorRectangle
    border.color: Style.colorBorder
    border.width: 1
}

