import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

TextField {
    id: text_field

    font.family: Style.font
    placeholderTextColor: Style.colorPlaceholderText

    // Right click Context Menu
    selectByMouse: true
    persistentSelection: true

    background: InnerBackground {
        radius: 100
    }

    RightClickMenu { }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

