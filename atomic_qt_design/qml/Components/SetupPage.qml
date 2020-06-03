import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

Item {
    property alias image: image
    property alias image_path: image.source
    property alias image_scale: image.scale
    property alias content: inner_space.sourceComponent
    property double image_margin: 5

    ColumnLayout {
        id: window_layout

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Center
        spacing: image_margin

        Image {
            id: image
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            antialiasing: true
        }

//        FloatingBackground {
//            id: rectangle
//            color: Style.colorTheme6
//            radius: 100
//            implicitWidth: image.implicitHeight
//            implicitHeight: image.implicitHeight
//            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
//            Image {
//                id: image
//                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.verticalCenter: parent.verticalCenter
//                antialiasing: true
//            }
//        }

        Pane {
            id: pane

            background: FloatingBackground {
                color: Style.colorTheme6
            }

            Loader {
                id: inner_space
            }
        }
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
