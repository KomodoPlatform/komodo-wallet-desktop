import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

MouseArea {
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

    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Cut")
            enabled: !text_field.readOnly && text_field.selectedText.length > 0
            onTriggered: text_field.cut()
        }
        MenuItem {
            text: qsTr("Copy")
            enabled: text_field.selectedText.length > 0
            onTriggered: text_field.copy()
        }
        MenuItem {
            text: qsTr("Paste")
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

