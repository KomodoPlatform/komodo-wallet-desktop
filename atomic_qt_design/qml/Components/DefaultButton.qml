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
    signal clicked()

    id: button_bg

    implicitWidth: 100
    implicitHeight: 50

    rect.color: !enabled ? Style.colorTheme9 : mouse_area.containsMouse ? Style.colorTheme6 : Style.colorTheme8

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
        color: !enabled ? Style.colorWhite8 : Style.colorWhite1
    }
}
