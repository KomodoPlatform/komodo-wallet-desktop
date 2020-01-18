import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

Item {
    Rectangle {
        color: Style.colorTheme6
        width: parent.width - sidebar.width
        height: parent.height
    }

    Rectangle {
        id: sidebar
        color: Style.colorTheme8
        width: 150
        height: parent.height
        x: parent.width - width

        Image {
            source: General.image_path + "komodo-icon.png"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.width * 0.25
            transformOrigin: Item.Center
            width: 64
            fillMode: Image.PreserveAspectFit
        }

        Sidebar {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
