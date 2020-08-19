import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

TextField {
    id: text_field

    property alias left_text: left_text.text_value
    property alias right_text: right_text.text_value

    font.family: Style.font_family
    placeholderTextColor: Style.colorPlaceholderText

    // Right click Context Menu
    selectByMouse: true
    persistentSelection: true

    background: InnerBackground {
        radius: 100
    }

    leftPadding: Math.max(0, left_text.width + 20)
    rightPadding: Math.max(0, right_text.width + 20)


    RightClickMenu { }

    DefaultText {
        id: left_text
        visible: text_value !== ""
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: text_field.font.pixelSize
    }

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

