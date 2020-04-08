import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QZXing 2.3

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("QRCode Test")


    Rectangle {
        anchors.fill: parent
        color: "red"

        TextField {
            id: inputField
            text: "Hello world!"
            anchors.top: parent.top
            anchors.topMargin: 30
        }

        Image{
            anchors.top: inputField.bottom
            anchors.topMargin: 30
            source: "image://QZXing/encode/" + inputField.text +
                            "?correctionLevel=M" +
                            "&format=qrcode"
            sourceSize.width: 320
            sourceSize.height: 320
        }
    }
}
