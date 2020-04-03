import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property bool copyable: false
    property bool hidable: false

    property bool hiding: true

    DefaultText {
        id: title_text
        visible: text !== ''
    }

    DefaultTextField {
        id: input_field

        echoMode: hidable && hiding ? TextInput.Password : TextInput.Normal

        Layout.fillWidth: true
        selectByMouse: true

        // Hide button
        Image {
            source: General.image_path + "dashboard-eye" + (hiding ? "" : "-hide") + ".svg"
            visible: hidable
            scale: 0.8
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: input_field.height * -0.0625
            antialiasing: true

            MouseArea {
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                height: input_field.height; width: input_field.height
                onClicked: hiding = !hiding
            }
        }

        CopyFieldButton {

        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
