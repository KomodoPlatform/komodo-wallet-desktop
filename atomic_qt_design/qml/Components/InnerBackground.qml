import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

Item {
    property alias content: inner_space.sourceComponent

    width: inner_space.width
    height: inner_space.height

    Rectangle {
        anchors.fill: parent
        radius: Style.rectangleCornerRadius
        color: Style.colorTheme7

        Loader {
            id: inner_space
        }
    }


    DefaultInnerShadow { }
}


