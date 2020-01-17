import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property bool hidable: false

    property bool hiding: true

    RowLayout {
        DefaultText {
            id: title_text
        }
    }

    TextField {
        id: input_field

        echoMode: hidable && hiding ? TextInput.Password : TextInput.Normal

        Layout.fillWidth: true
        selectByMouse: true

        Image {
            visible: hidable
            id: clearText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: input_field.height * -0.0625
            antialiasing: true
            source: General.image_path + "dashboard-eye" + (hiding ? "" : "-hide") + ".svg"
            scale: 0.8

            MouseArea {
                id: clear
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                height: input_field.height; width: input_field.height
                onClicked: hiding = !hiding
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
