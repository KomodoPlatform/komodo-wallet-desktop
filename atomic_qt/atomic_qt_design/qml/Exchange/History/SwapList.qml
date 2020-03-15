import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"
import ".."

Rectangle {
    property string title
    property alias items: list.model

    // Override
    function postCancelOrder() {}

    // Local
    function onCancelOrder(uuid) {
        API.get().cancel_order(uuid)
        postCancelOrder()
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    ColumnLayout {
        width: parent.width
        height: parent.height

        DefaultText {
            text: API.get().empty_string + (title + " (" + items.length + ")")

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
            visible: items.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            color: Style.colorWhite5

            text: API.get().empty_string + (qsTr("You don't have recent orders."))
        }

        // List
        ListView {
            id: list
            ScrollBar.vertical: ScrollBar {}
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            // Row
            delegate: OrderLine {
                item: General.formatOrder(model.modelData)
            }
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
