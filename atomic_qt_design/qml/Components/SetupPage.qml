import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

Item {
    property alias image_path: image.source
    property alias image_scale: image.scale
    property alias title: pane.title
    property alias content: pane.content

    ColumnLayout {
        id: window_layout

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Center
        spacing: 5

        Rectangle {
            id: rectangle
            color: Style.colorTheme6
            radius: 100
            implicitWidth: image.implicitHeight
            implicitHeight: image.implicitHeight
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Image {
                id: image
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true
            }
        }

        PaneWithTitle {
            id: pane
        }
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
