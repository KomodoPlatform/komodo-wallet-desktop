import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

Item {
    Rectangle {
        id: main
        color: Style.colorTheme6
        width: parent.width - sidebar.width
        height: parent.height
    }

    Rectangle {
        id: sidebar
        color: Style.colorTheme8
        width: 300
        height: parent.height
        x: parent.width - width
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
