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
        if(event.key === Qt.Key_Return) {
            if(onReturn !== undefined) {
                onReturn()
            }

            // Ignore \n \r stuff
            event.accepted = true
        }
    }

    onTextChanged: {
        text = text.replace(/[\r\n]/, '')
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

