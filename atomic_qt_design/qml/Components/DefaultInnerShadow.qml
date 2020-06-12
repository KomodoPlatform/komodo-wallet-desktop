import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

InnerShadow {
    cached: false
    horizontalOffset: 0.7
    verticalOffset: 0.7
    radius: 13
    samples: 32
    color: Style.colorInnerShadow
    smooth: true
}
