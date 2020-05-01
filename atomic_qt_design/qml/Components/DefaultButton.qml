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
    property string colorDisabled: Style.colorTheme9
    property string colorHovered: Style.colorTheme6
    property string colorEnabled: Style.colorTheme8
    property string colorTextDisabled: Style.colorWhite8
    property string colorTextEnabled: Style.colorWhite1

    signal clicked()

    id: button_bg

    implicitWidth: 100
    implicitHeight: 50

    rect.color: !enabled ? colorDisabled : mouse_area.containsMouse ? colorHovered : colorEnabled

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
        font.capitalization: Font.AllUppercase
        color: !parent.enabled ? colorTextDisabled : colorTextEnabled
    }
}
