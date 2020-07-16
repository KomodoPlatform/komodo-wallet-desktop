import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"


ColumnLayout {
    id: address_book

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

    // Contacts list
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

            // Contact card
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

                        // Contact name
                        DefaultText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.leftMargin: layout_margin
                            text: modelData.name
                            color: Style.colorText
                            visible: !editing

                            Component.onCompleted: {
                                // Start editing if it's a new/empty one
                                if(text.length === 0) editing = true
                            }
                        }
                        DefaultTextField {
                            id: name_input
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.leftMargin: layout_margin
                            color: Style.colorText
                            placeholderText: API.get().empty_string + (qsTr("Enter the contact name"))
                            width: 150
                            visible: editing
                        }

                        // Buttons
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
                                    name_input.text = modelData.name
                                    editing = true
                                }
                            }

                            PrimaryButton {
                                Layout.leftMargin: layout_margin

                                visible: editing
                                font.pixelSize: Style.textSizeSmall3
                                text: "💾"
                                minWidth: height
                                enabled: name_input.length > 0
                                onClicked: {
                                    modelData.name = name_input.text
                                    editing = false
                                }
                            }

                            DefaultButton {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: layout_margin

                                visible: !editing
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

                    // Address list
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

                                // Icon
                                Image {
                                    id: icon
                                    anchors.left: parent.left
                                    anchors.leftMargin: layout_margin
                                    anchors.verticalCenter: parent.verticalCenter

                                    source: General.coinIcon(type)
                                    fillMode: Image.PreserveAspectFit
                                    width: Style.textSize2
                                }

                                // Name
                                DefaultText {
                                    anchors.left: combo_base.anchors.left
                                    anchors.leftMargin: combo_base.anchors.leftMargin
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: !combo_base.visible

                                    text_value: API.get().empty_string + (type)
                                }
                                DefaultComboBox {
                                    id: combo_base
                                    anchors.left: icon.right
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: editing_address

                                    model: General.all_coins

                                    onModelChanged: {
                                        // When enabled_coins changes, all comboboxes reset to the first ticker
                                        // So we need to revert it to the old one
                                        if(type !== "") {
                                            const i = General.all_coins.indexOf(type)
                                            if(i !== -1) {
                                                currentIndex = i
                                            }
                                        }
                                    }

                                    property string previous_ticker
                                    onCurrentTextChanged: {
                                        type = currentText
                                    }
                                }

                                VerticalLine {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                }

                                // Address name
                                DefaultText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: address_input.anchors.leftMargin
                                    text: address
                                    visible: !address_input.visible
                                    font.pixelSize: Style.textSizeSmall3

                                    Component.onCompleted: {
                                        // Start editing if it's a new/empty one
                                        if(text.length === 0) editing_address = true
                                    }
                                }
                                DefaultTextField {
                                    id: address_input
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin * 7
                                    font.pixelSize: Style.textSizeSmall3
                                    placeholderText: API.get().empty_string + (qsTr("Enter the address"))
                                    width: 300
                                    visible: editing_address
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
                                            address_input.text = address
                                            editing_address = true
                                        }
                                    }

                                    PrimaryButton {
                                        Layout.leftMargin: layout_margin

                                        visible: editing_address
                                        font.pixelSize: Style.textSizeSmall3
                                        text: "💾"
                                        enabled: address_input.length > 0
                                        minWidth: height
                                        onClicked: {
                                            address = address_input.text
                                            editing_address = false
                                        }
                                    }

                                    DefaultButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.leftMargin: layout_margin

                                        font.pixelSize: Style.textSizeSmall3
                                        text: API.get().empty_string + (qsTr("Explorer"))
                                        enabled: address !== "" && type !== ""
                                        visible: !editing_address
                                        onClicked: General.viewAddressAtExplorer(type, address)
                                    }

                                    DefaultButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.leftMargin: layout_margin

                                        font.pixelSize: Style.textSizeSmall3
                                        text: API.get().empty_string + (qsTr("Send"))
                                        minWidth: height
                                        enabled: address !== "" && type !== "" && API.get().enabled_coins.map(c => c.ticker).indexOf(type) !== -1
                                        visible: !editing_address
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
