import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

Column {
    id: column
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    spacing: Style.paneTitleOffset

    property string title
    property alias content: inner_space.sourceComponent

    DefaultText {
        text: qsTr(title)
    }

    Pane {
        id: pane

        background: Rectangle {
            color: "#283547"
            radius: Style.rectangleCornerRadius
        }

        Loader {
            id: inner_space
        }
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
