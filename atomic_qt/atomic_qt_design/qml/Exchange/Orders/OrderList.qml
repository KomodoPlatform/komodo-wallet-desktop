import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

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
            delegate: Rectangle {
                color: "transparent"
                width: list.width
                height: 200

                ColumnLayout {
                    width: parent.width * 0.8
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Content
                    Rectangle {
                        Layout.topMargin: 12.5
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Base Icon
                        Image {
                            id: base_icon
                            source: General.coinIcon(model.modelData.am_i_maker ? model.modelData.base : model.modelData.rel)
                            fillMode: Image.PreserveAspectFit
                            width: Style.textSize3
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width * 0.25
                        }

                        // Rel Icon
                        Image {
                            id: rel_icon
                            source: General.coinIcon(model.modelData.am_i_maker ? model.modelData.rel : model.modelData.base)
                            fillMode: Image.PreserveAspectFit
                            width: Style.textSize3
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width * 0.25
                        }

                        // Base Amount
                        DefaultText {
                            id: base_amount
                            text: "~ " + General.formatCrypto("", model.modelData.am_i_maker ? model.modelData.base_amount : model.modelData.rel_amount,
                                                                  model.modelData.am_i_maker ? model.modelData.base : model.modelData.rel)
                            anchors.left: parent.left
                            anchors.top: base_icon.bottom
                            anchors.topMargin: 10
                        }

                        // Swap icon
                        Image {
                            source: General.image_path + "exchange-exchange.svg"
                            anchors.top: base_amount.top
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Rel Amount
                        DefaultText {
                            text: "~ " + General.formatCrypto("", model.modelData.am_i_maker ? model.modelData.rel_amount : model.modelData.base_amount,
                                                                  model.modelData.am_i_maker ? model.modelData.rel : model.modelData.base)
                            anchors.right: parent.right
                            anchors.top: base_amount.top
                        }

                        // UUID
                        DefaultText {
                            id: uuid
                            text: "UUID: " + model.modelData.uuid
                            color: Style.colorTheme2
                            anchors.top: base_amount.bottom
                            anchors.topMargin: base_amount.anchors.topMargin
                        }

                        // Date
                        DefaultText {
                            id: date
                            text: model.modelData.date
                            color: Style.colorTheme2
                            anchors.top: uuid.bottom
                            anchors.topMargin: base_amount.anchors.topMargin
                        }

                        // Cancel button
                        Button {
                            visible: model.modelData.cancellable
                            anchors.right: parent.right
                            anchors.top: date.top
                            text: qsTr("Cancel")
                            onClicked: onCancelOrder(model.modelData.uuid)
                        }
                    }

                    HorizontalLine {
                        visible: index !== items.length -1
                        Layout.fillWidth: true
                        color: Style.colorWhite9
                        Layout.topMargin: 25
                        Layout.bottomMargin: 12.5
                    }
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
