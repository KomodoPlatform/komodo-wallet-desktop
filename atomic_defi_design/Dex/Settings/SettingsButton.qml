import QtQuick 2.15
import "../Components/"
import App 1.0
import QtQuick.Layouts 1.15
import Qaterial 1.0 as Qaterial 

RowLayout
{
    id: control
    property bool noBackground: false
    
    signal clicked()
    
    property string title
    property string buttonText

    anchors.horizontalCenter: parent.horizontalCenter

    DexLabel
    {
        Layout.alignment: Qt.AlignVCenter
        font: DexTypo.subtitle1
        text: control.title // qsTr("Logs")
    }

    Item { Layout.fillWidth: true }

    DexAppButton
    {
        visible: control.noBackground
        Layout.alignment: Qt.AlignVCenter
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

    DexAppOutlineButton
    {
        Layout.alignment: Qt.AlignVCenter
        leftPadding: 20 
        rightPadding: 20
        radius: 20
        visible: !control.noBackground
        text: control.buttonText //qsTr("Open Folder")
        onClicked: control.clicked()
    }
}
