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
            property bool editing: false

            width: list.width
            height: contact_bg.height + layout_margin

            FloatingBackground {
                id: contact_bg

                width: parent.width - 2*layout_margin
                height: column_layout.height + layout_margin
                anchors.centerIn: parent

                ColumnLayout {
                    id: column_layout
                    width: parent.width
                    anchors.centerIn: parent

                    RowLayout {
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: 50
                        Layout.alignment: Qt.AlignVCenter

                        DefaultText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.leftMargin: layout_margin
                            text_value: modelData.name + " (" + modelData.readonly_addresses.length + ")"
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.rightMargin: layout_margin

                            DefaultButton {
                                Layout.leftMargin: layout_margin

                                visible: !editing
                                font.pixelSize: Style.textSizeSmall3
                                text: "✎"
                                minWidth: height
                                onClicked: {
                                    modelData.name = "Contact #" + index
                                    editing = true
                                }
                            }

                            PrimaryButton {
                                Layout.leftMargin: layout_margin

                                visible: editing
                                font.pixelSize: Style.textSizeSmall3
                                text: "💾"
                                minWidth: height
                                onClicked: {
                                    editing = false
                                }
                            }

                            DefaultButton {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: layout_margin

                                font.pixelSize: Style.textSizeSmall3
                                text: "New Address"
                                onClicked: {
                                    modelData.add_address_content()
                                }
                            }

                            DangerButton {
                                Layout.alignment: Qt.AlignVCenter
                                visible: editing
                                Layout.leftMargin: layout_margin

                                font.pixelSize: Style.textSizeSmall3
                                text: "🗑"
                                minWidth: height
                                onClicked: {
                                    API.get().addressbook_mdl.remove_at(index)
                                }
                            }
                        }
                    }

                    HorizontalLine {
                        Layout.fillWidth: true
                    }

                    Column {
                        Layout.fillWidth: true

                        Repeater {
                            id: address_list

                            model: modelData
                            delegate: Rectangle {
                                property bool editing_address: false

                                width: contact_bg.width
                                height: 50

                                color: mouse_area.containsMouse ? Style.colorTheme6 : "transparent"

                                MouseArea {
                                    id: mouse_area
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                                DefaultText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin

                                    font.pixelSize: Style.textSizeSmall3
                                    text_value: "COIN: " + type
                                }

                                DefaultText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin * 5

                                    font.pixelSize: Style.textSizeSmall3
                                    text_value: "ADDRESS: " + address
                                }

                                RowLayout {
                                    anchors.right: parent.right
                                    anchors.rightMargin: layout_margin
                                    anchors.verticalCenter: parent.verticalCenter

                                    DefaultButton {
                                        Layout.leftMargin: layout_margin

                                        visible: !editing_address
                                        font.pixelSize: Style.textSizeSmall3
                                        text: "✎"
                                        minWidth: height
                                        onClicked: {
                                            type = "BTC"
                                            address = "3KFCRfjE4DYsqtoB9CsYgAvhD6D3Noi2fq"

                                            editing_address = true
                                        }
                                    }

                                    PrimaryButton {
                                        Layout.leftMargin: layout_margin

                                        visible: editing_address
                                        font.pixelSize: Style.textSizeSmall3
                                        text: "💾"
                                        minWidth: height
                                        onClicked: {
                                            editing_address = false
                                        }
                                    }

                                    DefaultButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.leftMargin: layout_margin

                                        font.pixelSize: Style.textSizeSmall3
                                        text: API.get().empty_string + (qsTr("Explorer"))
                                        enabled: address !== ""
                                        onClicked: General.viewAddressAtExplorer(type, address)
                                    }

                                    DefaultButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: editing_address
                                        Layout.leftMargin: layout_margin

                                        font.pixelSize: Style.textSizeSmall3
                                        text: API.get().empty_string + (qsTr("Send"))
                                        minWidth: height
                                        enabled: address !== ""
                                        onClicked: {
                                            console.log("Will open send modal for this address")
                                        }
                                    }

                                    DangerButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: editing_address
                                        Layout.leftMargin: layout_margin

                                        font.pixelSize: Style.textSizeSmall3
                                        text: "🗑"
                                        minWidth: height
                                        onClicked: {
                                            modelData.remove_at(index)
                                        }
                                    }
                                }

                                HorizontalLine {
                                    visible: index !== modelData.length -1
                                    width: parent.width - 4

                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: -height/2
                                    light: true
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
