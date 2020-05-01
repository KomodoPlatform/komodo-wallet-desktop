import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"
import "../Components"

DefaultRectangle {
    id: sidebar
    x: -radius
    width: 200 - x
    height: parent.height
    radius: Style.rectangleCornerRadius

    DefaultGradient { }

    Item {
        anchors.right: parent.right
        width: parent.width + parent.x
        height: parent.height

        Image {
            source: General.image_path + "atomicdex-logo.svg"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.width * 0.25
            transformOrigin: Item.Center
            height: 85
            fillMode: Image.PreserveAspectFit
        }

        Separator {
            anchors.bottom: version_text.top
            anchors.bottomMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
        }

        DefaultText {
            id: version_text
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.width * 0.85
            text: API.get().empty_string + ("V. AtomicDEX PRO " + API.get().get_version())
            font.pixelSize: Style.textSizeVerySmall8
            color: Style.colorThemeDarkLight
        }

        SidebarCenter {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
        }

        SidebarBottom {
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width * 0.25
        }
    }
}







/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:150}
}
##^##*/
