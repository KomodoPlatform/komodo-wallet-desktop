import QtQuick 2.15
import "../Constants"

// Add button
FloatingBackground {
    property alias containsMouse: mouse_area.containsMouse
    property alias text: text_obj.text_value
    property alias text_obj: text_obj
    property bool text_left_align: false
    property double text_offset: 0
    property alias font: text_obj.font
    property string button_type: "default"
    property string colorDisabled: theme.buttonColorDisabled
    property string colorHovered: theme.buttonColorHovered
    property string colorEnabled: theme.buttonColorEnabled
    property string colorTextDisabled: theme.buttonColorTextDisabled
    property string colorTextHovered: theme.buttonColorTextHovered
    property string colorTextEnabled: theme.buttonColorTextEnabled
    property real textScale: 1
    property int minWidth: 90

    signal clicked()

    id: button_bg

    implicitWidth: Math.max(minWidth, text_obj.width + 20 + Math.abs(text_offset))
    implicitHeight: text_obj.height * 2.5

    color: !enabled ? colorDisabled : mouse_area.containsMouse ? colorHovered : colorEnabled

    DexText {
        id: text_obj
        anchors.horizontalCenter: text_left_align ? undefined : parent.horizontalCenter
        anchors.horizontalCenterOffset: text_left_align ? 0 : text_offset
        anchors.left: text_left_align ? parent.left : undefined
        anchors.leftMargin: text_left_align ? -text_offset : 0
        anchors.verticalCenter: parent.verticalCenter
        font: Qt.font({
            pixelSize: 14*textScale,
            letterSpacing: 1.25,
            capitalization: Font.AllUppercase,
            family: _font.fontFamily,
            weight: Font.Medium
        })
        color: !parent.enabled ? colorTextDisabled : mouse_area.containsMouse ? colorTextHovered : colorTextEnabled
    }

    DefaultMouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if(parent.enabled) parent.clicked()
        }
    }
}
