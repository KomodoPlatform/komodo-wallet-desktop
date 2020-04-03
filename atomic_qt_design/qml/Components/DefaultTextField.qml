import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

TextField {
    id: text_field

    // Right click Context Menu
    selectByMouse: true
    persistentSelection: true

    RightClickMenu {

    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

