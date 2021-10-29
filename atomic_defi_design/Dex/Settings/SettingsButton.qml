import QtQuick 2.15
import "../Components/"
import App 1.0
import Qaterial 1.0 as Qaterial 

Item {
    id: control
    property bool noBackground: false
    
    signal clicked()
    
    property string title
    property string buttonText

    anchors.horizontalCenter: parent.horizontalCenter

    DexLabel {
        anchors.verticalCenter: parent.verticalCenter
        font: DexTypo.subtitle1
        text: control.title // qsTr("Logs")
    }

    DexAppButton {
        visible: control.noBackground
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        text: control.buttonText
        color: containsMouse ? DexTheme.buttonColorHovered : 'transparent'
        height: 48
        radius: 20
        font: Qt.font({
            pixelSize: 19 ,
            letterSpacing: 0.15,
            family: DexTypo.fontFamily,
            underline: true,
            weight: Font.Normal
        })
        iconSource: Qaterial.Icons.logout
        onClicked: control.clicked()
    }

    DexAppOutlineButton {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        leftPadding: 20 
        rightPadding: 20
        radius: 20
        visible: !control.noBackground
        text: control.buttonText //qsTr("Open Folder")
        onClicked: control.clicked()
    }
}
