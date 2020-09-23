import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"

DefaultMouseArea {
    function openContextMenu(x, y) {
        contextMenu.x = x;
        contextMenu.y = y;
        contextMenu.open();
    }

    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    hoverEnabled: true
    onClicked: openContextMenu(mouse.x, mouse.y)
    onPressAndHold: {
        if (mouse.source === Qt.MouseEventNotSynthesized)
            openContextMenu(mouse.x, mouse.y)
    }

    cursorShape: Qt.IBeamCursor

    Menu {
        id: contextMenu

        MenuItem {
            text: API.app.settings_pg.empty_string + (qsTr("Cut"))
            enabled: !text_field.readOnly && text_field.selectedText.length > 0 && text_field.echoMode !== TextInput.Password
            onTriggered: text_field.cut()
        }
        MenuItem {
            text: API.app.settings_pg.empty_string + (qsTr("Copy"))
            enabled: text_field.selectedText.length > 0 && text_field.echoMode !== TextInput.Password
            onTriggered: text_field.copy()
        }
        MenuItem {
            text: API.app.settings_pg.empty_string + (qsTr("Paste"))
            enabled: !text_field.readOnly
            onTriggered: text_field.paste()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

