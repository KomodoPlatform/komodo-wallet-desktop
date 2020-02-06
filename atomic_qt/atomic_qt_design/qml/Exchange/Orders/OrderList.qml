import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Rectangle {
    property alias title: title.text
    property alias model: list.model
    property string type

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    ColumnLayout {
        width: parent.width

        DefaultText {
            id: title

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 10

            font.pointSize: Style.textSize2
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        // No orders
        DefaultText {
            wrapMode: Text.Wrap
            visible: model.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            color: Style.colorWhite5

            text: qsTr("You don't have any ") + type + qsTr(" orders.")
        }

        // List
        ListView {
            id: list
            ScrollBar.vertical: ScrollBar {}
            Layout.topMargin: Style.textSize*2
            Layout.fillWidth: true
            implicitHeight: contentItem.childrenRect.height

            clip: true

            // Row
            delegate: Rectangle {
                color: Style.colorTheme6
                width: list.width
                implicitHeight: childrenRect.height
                Layout.topMargin: 10

                DefaultText {
                    text: model.modelData.date
                }

                DefaultText {
                    text: model.modelData.base_amount
                }
            }
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
