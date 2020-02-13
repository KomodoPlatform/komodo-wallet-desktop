import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"
import ".."

Rectangle {
    property string title
    property alias items: list.model
    property string type

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
            text: title + " (" + items.length + ")"

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

            text: qsTr("You don't have any ") + type + qsTr(" orders.")
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
                item: (() => {
                    let o = model.modelData
                    o.my_info = {
                        my_coin: o.am_i_maker ? o.base : o.rel,
                        my_amount: o.am_i_maker ? o.base_amount : o.rel_amount,
                        other_coin: o.am_i_maker ? o.rel : o.base,
                        other_amount: o.am_i_maker ? o.rel_amount : o.base_amount,
                    }
                    return o
                })()
            }
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
