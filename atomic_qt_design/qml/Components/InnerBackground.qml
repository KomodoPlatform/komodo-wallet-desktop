import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import "../Constants"

Item {
    property alias content: inner_space.sourceComponent
    property alias color: rect.color
    property alias radius: rect.radius
    property alias border: rect.border


    width: inner_space.width
    height: inner_space.height


    Item {
        id: rect_with_shadow
        anchors.fill: parent

        DefaultRectangle {
            id: rect
            anchors.fill: parent
            border.color: "transparent"
            color: Style.colorInnerBackground

            Loader {
                anchors.centerIn: parent
                id: inner_space

                layer.enabled: true

                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: inner_space.width
                        height: inner_space.height
                        radius: rect.radius
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: DefaultInnerShadow { }
    }

    LinearGradient {
        id: gradient
        visible: rect.border.width > 0
        source: rect
        width: rect.width + rect.border.width*2
        height: rect.height + rect.border.width*2
        anchors.centerIn: parent

        z: -1
        start: Qt.point(0, 0)
        end: Qt.point(0, height)

        gradient: Gradient {
            GradientStop {
               position: 0.35
               color: Style.colorRectangleBorderGradient2
            }
            GradientStop {
               position: 0.65
               color: Style.colorRectangleBorderGradient1
            }
        }
    }
}
