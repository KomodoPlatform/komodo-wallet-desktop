import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import "../Constants"

// Add button
FloatingBackground {
    property alias containsMouse: mouse_area.containsMouse
    property alias text: text_obj.text_value
    property alias text_obj: text_obj
    property bool text_left_align: false
    property double text_offset: 0
    property alias font: text_obj.font
    property string colorDisabled: Style.colorButtonDisabled
    property string colorHovered: Style.colorButtonHovered
    property string colorEnabled: Style.colorButtonEnabled
    property string colorTextDisabled: Style.colorButtonTextDisabled
    property string colorTextHovered: Style.colorButtonTextHovered
    property string colorTextEnabled: Style.colorButtonTextEnabled

    signal clicked()

    id: button_bg

    implicitWidth: Math.max(90, text_obj.width + 20 + Math.abs(text_offset))
    implicitHeight: 40

    radius: 100

    color: !enabled ? colorDisabled : mouse_area.containsMouse ? colorHovered : colorEnabled
    border.width: 0

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if(parent.enabled) parent.clicked()
        }
    }

    DefaultText {
        id: text_obj
        anchors.horizontalCenter: text_left_align ? undefined : parent.horizontalCenter
        anchors.horizontalCenterOffset: text_left_align ? 0 : text_offset
        anchors.left: text_left_align ? parent.left : undefined
        anchors.leftMargin: text_left_align ? -text_offset : 0
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Style.textSizeSmall1
        font.capitalization: Font.AllUppercase
        color: !parent.enabled ? colorTextDisabled : mouse_area.containsMouse ? colorTextHovered : colorTextEnabled
    }
}
