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
        text: control.title
    }

    Item { Layout.fillWidth: true }


    Item
    {
        width: 120
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 200

        Row
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            DexAppButton
            {
                visible: control.noBackground
                text: control.buttonText
                color: containsMouse ? DexTheme.buttonColorHovered : 'transparent'
                height: 40
                radius: 20
                padding: 20
                font: DexTypo.body1
                iconSource: Qaterial.Icons.logout
                onClicked: control.clicked()
            }

            DexAppOutlineButton
            {
                height: 40
                padding: 20
                radius: 20
                font: DexTypo.body1
                visible: !control.noBackground
                text: control.buttonText
                onClicked: control.clicked()
            }
        }
    }
}
