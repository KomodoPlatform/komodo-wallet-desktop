import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12


import QtQuick 2.15
import QtGraphicalEffects 1.12
import Qaterial 1.0 as Qaterial
import "../Constants"
import App 1.0

Item {
    id: control
    property alias content: inner_space.sourceComponent
    property alias color: rect.color
    property alias radius: rect.radius
    property alias border: rect.border
    property bool shadowOff: false
    property bool auto_set_size: true

    implicitWidth: auto_set_size ? inner_space.width : 0
    implicitHeight: auto_set_size ? inner_space.height : 0

    Item {
        id: rect_with_shadow
        anchors.fill: parent

        DefaultRectangle {
            id: rect
            anchors.fill: parent
            border.color: "transparent"
            color: DexTheme.backgroundColor

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
    }
}
