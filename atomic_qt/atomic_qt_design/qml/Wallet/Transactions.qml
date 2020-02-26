import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// List
ListView {
    ScrollBar.vertical: ScrollBar {}
    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height

    model: API.get().current_coin_info.transactions
    clip: true

    function reset() {

    }

    // Row
    delegate: Rectangle {
        id: rectangle
        color: "transparent"
        implicitWidth: parent.width
        height: 65

        visible: model.modelData.timestamp !== 0

        // Icon
        Image {
            id: received_icon
            source: General.image_path + "circle-" + (model.modelData.received ? "success" : "failed") + ".png"
            fillMode: Image.PreserveAspectFit
            width: Style.textSize2
            anchors.verticalCenter: parent.verticalCenter
        }

        // Amount
        ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 450

            // Crypto
            DefaultText {
                text: General.formatCrypto(model.modelData.received, model.modelData.amount, API.get().current_coin_info.ticker)
                Layout.alignment: Qt.AlignRight
                font.pointSize: Style.textSize2
            }

            // Fiat
            DefaultText {
                text: General.formatFiat(model.modelData.received, model.modelData.amount_fiat, API.get().fiat)
                Layout.topMargin: -10
                Layout.rightMargin: 4
                Layout.alignment: Qt.AlignRight
                font.pointSize: Style.textSize
                color: Style.colorWhite4
            }
        }

        // Date
        DefaultText {
            anchors.right: parent.right
            anchors.rightMargin: 170
            text: model.modelData.date
            anchors.verticalCenter: parent.verticalCenter
        }

        // Info button
        Button {
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Details")
            onClicked: tx_details_modal.open()
        }

//        Image {
//            anchors.right: parent.right
//            anchors.rightMargin: 50
//            source: General.image_path + "dashboard-info.svg"
//            fillMode: Image.PreserveAspectFit
//            width: Style.textSize2
//            anchors.verticalCenter: parent.verticalCenter

//            MouseArea {
//                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
//                height: parent.height * 2; width: height
//                onClicked: tx_details_modal.open()
//            }
//        }

        TransactionDetailsModal {
            id: tx_details_modal
            details: model.modelData
        }
    }
}







/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
