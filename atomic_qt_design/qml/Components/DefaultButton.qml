import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Constants"

// Add button
FloatingBackground {
    property alias containsMouse: mouse_area.containsMouse
    property alias text: text_obj.text
    property alias font: text_obj.font
    property string colorDisabled: Style.colorButtonDisabled
    property string colorHovered: Style.colorButtonHovered
    property string colorEnabled: Style.colorButtonEnabled
    property string colorTextDisabled: Style.colorButtonTextDisabled
    property string colorTextHovered: Style.colorButtonTextHovered
    property string colorTextEnabled: Style.colorButtonTextEnabled

    signal clicked()

    id: button_bg

    implicitWidth: Math.max(90, text_obj.width + 20)
    implicitHeight: 40

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
        anchors.centerIn: parent
        font.pixelSize: Style.textSizeSmall3
        font.weight: Font.Medium
        font.capitalization: Font.AllUppercase
        color: !parent.enabled ? colorTextDisabled : mouse_area.containsMouse ? colorTextHovered : colorTextEnabled
    }
}
