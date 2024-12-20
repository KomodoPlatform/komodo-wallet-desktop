import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Constants"
import App 1.0
import Dex.Components 1.0 as Dex
import Dex.Themes 1.0 as Dex

TextArea {
    id: text_field

    font.family: Style.font_family

    color: Dex.CurrentTheme.foregroundColor
    placeholderTextColor: Dex.CurrentTheme.colorPlaceholderText
    selectedTextColor: Dex.CurrentTheme.colorSelectedText
    selectionColor: Dex.CurrentTheme.colorSelection

    Behavior on color {
        ColorAnimation {
            duration: Style.animationDuration
        }
    }
    Behavior on placeholderTextColor {
        ColorAnimation {
            duration: Style.animationDuration
        }
    }

    property bool remove_newline: true
    wrapMode: TextEdit.Wrap

    Keys.onBacktabPressed: nextItemInFocusChain(false).forceActiveFocus(Qt.TabFocusReason)
    Keys.onTabPressed: nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)

    Keys.onPressed: {
        if (event.key === Qt.Key_Return) {
            if (onReturn !== undefined) {
                onReturn()
            }

            // Ignore \n \r stuff
            if (remove_newline) event.accepted = true
        }
    }

    onTextChanged: {
        if (remove_newline) {
            if (text.indexOf('\r') !== -1 || text.indexOf('\n') !== -1) {
                text = text.replace(/[\r\n]/, '')
            }
        }
    }

    // Right click Context Menu
    selectByMouse: true
    persistentSelection: true

    background: InnerBackground {}

    RightClickMenu {}
}