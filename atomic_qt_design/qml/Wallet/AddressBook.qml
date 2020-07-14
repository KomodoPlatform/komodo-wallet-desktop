import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"


ColumnLayout {
    Layout.fillWidth: true

    spacing: 20

    DefaultText {
        Layout.leftMargin: layout_margin
        text_value: API.get().empty_string + ("< " + qsTr("Back"))
        font.bold: true

        MouseArea {
            anchors.fill: parent
            onClicked: main_layout.currentIndex = 0
        }
    }

    RowLayout {
        Layout.leftMargin: layout_margin
        Layout.fillWidth: true

        DefaultText {
            text_value: API.get().empty_string + (qsTr("Address Book"))
            font.bold: true
            font.pixelSize: Style.textSize3
            Layout.fillWidth: true
        }

        DefaultButton {
            Layout.rightMargin: layout_margin
            Layout.alignment: Qt.AlignRight
            text: API.get().empty_string + (qsTr("New Contact"))
            onClicked: {
                API.get().addressbook_mdl.add_contact_entry()
            }
        }
    }

    HorizontalLine {
        Layout.fillWidth: true
    }

    DefaultListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: API.get().addressbook_mdl

        delegate: Item {
            readonly property int line_height: 200
            readonly property bool is_last_item: index === model.length - 1

            width: list.width
            height: contact_bg.height + layout_margin

            FloatingBackground {
                id: contact_bg

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: layout_margin
                anchors.rightMargin: anchors.leftMargin

                content: ColumnLayout {
                    DefaultText {
                        Layout.topMargin: layout_margin
                        Layout.leftMargin: layout_margin
                        text_value: modelData.name
                    }

                    DefaultButton {
                        Layout.leftMargin: layout_margin

                        font.pixelSize: Style.textSizeSmall3
                        text: "Edit"
                        onClicked: {
                            modelData.name = "Contact #" + index
                        }
                    }

                    DefaultButton {
                        Layout.leftMargin: layout_margin

                        font.pixelSize: Style.textSizeSmall3
                        text: "Delete"
                        onClicked: {
                            API.get().addressbook_mdl.remove_at(index)
                        }
                    }

                    DefaultButton {
                        Layout.leftMargin: layout_margin

                        font.pixelSize: Style.textSizeSmall3
                        text: "New Address"
                        onClicked: {
                            modelData.add_address_content()
                        }
                    }

                    HorizontalLine {
                        Layout.fillWidth: true
                    }

                    Column {
                        Layout.bottomMargin: layout_margin
                        Layout.fillWidth: true

                        Repeater {
                            id: address_list

                            model: modelData
                            delegate: Item {
                                width: contact_bg.width

                                height: 25

                                DefaultButton {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin * 7

                                    font.pixelSize: Style.textSizeSmall3
                                    text: "SET"
                                    onClicked: {
                                        type = "Kek" + index
                                        address = index + "-lsdkfja;lskdfjasdflaskdv"
                                    }
                                }

                                DefaultText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin

                                    font.pixelSize: Style.textSizeSmall3
                                    text_value: "TYPE: " + type
                                }

                                DefaultText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin * 5

                                    font.pixelSize: Style.textSizeSmall3
                                    text_value: "ADDRESS: " + address
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
