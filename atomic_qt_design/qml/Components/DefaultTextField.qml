import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

TextField {
    id: text_field

    property alias right_text: right_text.text_value

    font.family: Style.font_family
    placeholderTextColor: Style.colorPlaceholderText

    // Right click Context Menu
    selectByMouse: true
    persistentSelection: true

    background: InnerBackground {
        radius: 100
    }

    RightClickMenu { }

    DefaultText {
        id: right_text
        visible: text_value !== ""
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: text_field.font.pixelSize
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

