import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

TextArea {
    id: text_field

    wrapMode: TextEdit.Wrap

    KeyNavigation.priority: KeyNavigation.BeforeItem
    KeyNavigation.backtab: nextItemInFocusChain(false)
    KeyNavigation.tab: nextItemInFocusChain(true)
    Keys.onPressed: {
        if(onReturn !== undefined && event.key === Qt.Key_Return) {
            onReturn()
            event.accepted = true
        }
    }


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

