import QtQuick 2.15
import QtGraphicalEffects 1.12
import Qaterial 1.0 as Qaterial
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

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
    property color bottomBorderColor: DexTheme.theme === "light" ? DexTheme.contentColorTopBold : DexTheme.colorInnerShadowBottom
    property color topBorderColor: DexTheme.theme === "light" ? DexTheme.contentColorTopBold : DexTheme.colorInnerShadowTop

    Item
    {
        id: rect_with_shadow
        anchors.fill: parent

        DexRectangle
        {
            id: rect
            anchors.fill: parent
            color: Dex.CurrentTheme.accentColor
            border.color: color

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

        layer.enabled: !control.shadowOff
        layer.effect: DefaultInnerShadow { }
    }
}
