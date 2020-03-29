import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property bool copyable: false
    property var onReturn // function


    // Local
    function reset() {
        input_field.text = ''
    }

    RowLayout {
        DefaultText {
            id: title_text
        }
    }

    TextArea {
        id: input_field
        Layout.fillWidth: true
        selectByMouse: true
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

        // Copy button
        Image {
            source: General.image_path + "dashboard-copy.svg"
            visible: copyable
            scale: 0.8
            anchors.right: parent.right
            y: -height
            antialiasing: true

            MouseArea {
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                height: input_field.height; width: input_field.height
                onClicked: () => {
                    input_field.selectAll()
                    input_field.copy()
                }
            }
        }
    }
}


