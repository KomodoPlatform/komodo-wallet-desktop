import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// List
ListView {
    ScrollBar.vertical: ScrollBar {}
    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height

    model: {
        const confirmed = API.get().current_coin_info.transactions.filter(t => t.timestamp !== 0)
        const unconfirmed = API.get().current_coin_info.transactions.filter(t => t.timestamp === 0)
        return unconfirmed.concat(confirmed)
    }
    clip: true

    function reset() {

    }

    // Row
    delegate: Rectangle {
        id: rectangle
        implicitWidth: parent.width
        height: 65

        property bool hovered: false

        color: hovered ? Style.colorTheme8 : "transparent"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onHoveredChanged: hovered = containsMouse
            onClicked: tx_details_modal.open()
        }

        TransactionDetailsModal {
            id: tx_details_modal
            details: model.modelData
        }

        // Icon
        Image {
            id: received_icon
            source: General.image_path + "circle-" + (model.modelData.received ? "success" : "failed") + ".png"
            fillMode: Image.PreserveAspectFit
            width: Style.textSize2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: 350
        }

        // Amount
        ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: -100

            // Crypto
            DefaultText {
                text: API.get().empty_string + (General.formatCrypto(model.modelData.received, model.modelData.amount, API.get().current_coin_info.ticker))
                Layout.alignment: Qt.AlignRight
                font.pixelSize: Style.textSize2
            }

            // Fiat
            DefaultText {
                text: API.get().empty_string + (General.formatFiat(model.modelData.received, model.modelData.amount_fiat, API.get().fiat))
                Layout.topMargin: -10
                Layout.rightMargin: 4
                Layout.alignment: Qt.AlignRight
                font.pixelSize: Style.textSize
                color: Style.colorWhite4
            }
        }

        // Date
        DefaultText {
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: -380
            text: API.get().empty_string + (model.modelData.timestamp === 0 ? qsTr("Unconfirmed"):  model.modelData.date)
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}







/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
