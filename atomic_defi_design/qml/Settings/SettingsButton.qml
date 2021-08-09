import QtQuick 2.15
import "../Components/"

Item {
    id: control
    
    signal clicked()
    
    property string title
    property string buttonText

    anchors.horizontalCenter: parent.horizontalCenter

    DexLabel {
        anchors.verticalCenter: parent.verticalCenter
        text: control.title // qsTr("Logs")
    }

    DexAppButton {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        text: control.buttonText //qsTr("Open Folder")
        onClicked: control.clicked()
    }
}