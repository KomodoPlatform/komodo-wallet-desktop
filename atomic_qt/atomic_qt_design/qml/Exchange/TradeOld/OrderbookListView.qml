import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

ColumnLayout {
    property string value_color
    property alias model: list.model

    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        id: header
        Layout.topMargin: Style.textSize

        Layout.fillWidth: true
        color: "transparent"

        DefaultText {
            id: header_price
            anchors.right: parent.right
            anchors.rightMargin: list.width * 0.5 + 20
            text: qsTr("Price")
        }

        DefaultText {
            id: header_volume
            anchors.right: parent.right
            anchors.rightMargin: 25
            text: qsTr("Volume")
        }
    }

    ListView {
        id: list
        ScrollBar.vertical: ScrollBar {}
        Layout.topMargin: Style.textSize*2
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: contentItem.childrenRect.height

        clip: true

        // Row
        delegate: Rectangle {
            color: "transparent"
            width: list.width
            height: list.Layout.topMargin

            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: header_price.anchors.rightMargin
                text: model.modelData.price
                color: value_color
            }

            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: header_volume.anchors.rightMargin
                text: model.modelData.maxvolume
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
