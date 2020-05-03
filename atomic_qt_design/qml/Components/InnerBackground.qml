import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

Item {
    property alias content: inner_space.sourceComponent
    property alias color: rect.color
    property alias radius: rect.radius
    property alias border: rect.border

    width: inner_space.width
    height: inner_space.height

    DefaultRectangle {
        id: rect
        anchors.fill: parent

        Loader {
            anchors.centerIn: parent
            id: inner_space
        }
    }

    layer.enabled: true
    layer.effect: DefaultInnerShadow { }
}


