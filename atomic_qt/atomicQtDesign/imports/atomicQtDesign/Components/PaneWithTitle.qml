import QtQuick 2.12
import atomicQtDesign 1.0
import QtQuick.Layouts 1.3
import Qt.SafeRenderer 1.1
import QtQuick.Studio.Effects 1.0
import QtQuick.Studio.Components 1.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12

Column {
    id: column
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    spacing: Constants.stylePaneTitleOffset

    property string title
    property alias inside: inner_space.sourceComponent

    DefaultText {
        text: qsTr(title)
    }

    Pane {
        id: pane

        background: Rectangle {
            color: "#283547"
            radius: Constants.styleRadius
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
