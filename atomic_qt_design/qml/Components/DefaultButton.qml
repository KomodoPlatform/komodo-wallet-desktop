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
    property string colorDisabled: Style.colorTheme9
    property string colorHovered: Style.colorTheme6
    property string colorEnabled: Style.colorTheme8
    property string colorTextDisabled: Style.colorWhite8
    property string colorTextHovered: Style.colorWhite1
    property string colorTextEnabled: Style.colorWhite1 // Style.colorThemePassive

    signal clicked()

    id: button_bg

    implicitWidth: Math.max(90, text_obj.width + 20)
    implicitHeight: 40

    rect.color: !enabled ? colorDisabled : mouse_area.containsMouse ? colorHovered : colorEnabled
    rect.border.width: 0

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
