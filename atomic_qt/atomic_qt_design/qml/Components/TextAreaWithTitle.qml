import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property bool copyable: false

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

        // Hide button
        Image {
            source: General.image_path + "dashboard-copy.svg"
            visible: copyable
            scale: 0.8
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: input_field.height * -0.0625
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


