import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

Item {
    property alias image: img.source
    property alias text: txt.text

    Layout.fillWidth: true
    height: 48

    Image {
        id: img
        scale: 0.8
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    DefaultText {
        id: txt
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        width: parent.width
        height: parent.height
        onClicked: function() {

        }
    }
}


