import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"


ColumnLayout {
    id: address_book

    property bool global_edit_in_progress: false
    Layout.fillWidth: true

    readonly property var essential_coins: General.all_coins.filter(c => {
                    if(c.type === "ERC-20" && c.ticker !== "ETH") return false
                    if(c.type === "Smart Chain" && c.ticker !== "KMD") return false

                    return true
                })

    spacing: 20

    DefaultText {
        id: back_button
        property bool disabled: global_edit_in_progress
        Layout.leftMargin: layout_margin
        text_value: API.get().empty_string + ("< " + qsTr("Back"))
        font.bold: true
        color: disabled ? Style.colorTextDisabled : Style.colorText

        MouseArea {
            anchors.fill: parent
            onClicked: { if(!back_button.disabled) main_layout.currentIndex = 0 }
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
            enabled: !global_edit_in_progress
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
        model: API.get().addressbook_mdl.addressbook_proxy_mdl

        delegate: Item {
            id: contact
            readonly property int line_height: 200
            readonly property bool is_last_item: index === model.length - 1
            property bool editing: false

            readonly property var selected_coins: modelData.readonly_addresses.map(c => c.type)

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
                                if(text.length === 0) {
                                    editing = global_edit_in_progress = true
                                }
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
                                enabled: !global_edit_in_progress
                                font.pixelSize: Style.textSizeSmall3
                                text: "✎"
                                minWidth: height
                                onClicked: {
                                    name_input.text = modelData.name
                                    editing = global_edit_in_progress = true
                                }
                            }

                            PrimaryButton {
                                Layout.leftMargin: layout_margin

                                visible: editing
                                enabled: name_input.length > 0
                                font.pixelSize: Style.textSizeSmall3
                                text: "💾"
                                minWidth: height
                                onClicked: {
                                    modelData.name = name_input.text
                                    editing = global_edit_in_progress = false
                                }
                            }

                            DefaultButton {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: layout_margin

                                visible: !editing
                                enabled: !global_edit_in_progress && essential_coins.length > contact.selected_coins.length
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
                                    global_edit_in_progress = false
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
                                id: address_line
                                property bool editing_address: false


                                property var selectable_coins: ([])

                                Connections {
                                    target: contact

                                    function onSelected_coinsChanged() {
                                        address_line.updateSelectableCoins()
                                    }
                                }

                                function updateSelectableCoins() {
                                    selectable_coins = essential_coins.filter(c => {
                                                            return c.ticker === type || contact.selected_coins.indexOf(c.ticker) === -1
                                                        }).map(c => c.ticker)
                                }


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

                                    model: selectable_coins

                                    property int previous_type_index: -1
                                    property int type_index: -1
                                    onCurrentTextChanged: {
                                        // If index is same but the text changed, that means the list changed,
                                        // We'll change the index instead
                                        // We also always save the previous index, to recover from double reset later
                                        if(currentIndex === type_index) {
                                            // This part fixes the index shift when one element disappears
                                            previous_type_index = type_index
                                            currentIndex = type_index = selectable_coins.indexOf(type)
                                        }
                                        else if(currentText !== type) {
                                            // This part simply sets the ticker
                                            previous_type_index = type_index
                                            type_index = currentIndex
                                            type = currentText
                                        }
                                    }

                                    onModelChanged: {
                                        // When list resets, we already correct the index, but somehow it double resets
                                        // That's why we save the previous one before the second reset and recover to that here
                                        if(previous_type_index !== -1)
                                            currentIndex = previous_type_index
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
                                    anchors.leftMargin: layout_margin * 5
                                    text: address
                                    visible: !address_input.visible
                                    font.pixelSize: Style.textSizeSmall3

                                    Component.onCompleted: {
                                        // Start editing if it's a new/empty one
                                        if(text.length === 0) {
                                            editing_address = global_edit_in_progress = true
                                        }
                                    }
                                }
                                AddressField {
                                    id: address_input
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin * 7
                                    font.pixelSize: Style.textSizeSmall3
                                    placeholderText: API.get().empty_string + (qsTr("Enter the address"))
                                    width: 400
                                    visible: editing_address
                                }

                                RowLayout {
                                    anchors.right: parent.right
                                    anchors.rightMargin: layout_margin
                                    anchors.verticalCenter: parent.verticalCenter

                                    DefaultButton {
                                        Layout.leftMargin: layout_margin

                                        visible: !editing_address
                                        enabled: !global_edit_in_progress
                                        font.pixelSize: Style.textSizeSmall3
                                        text: "✎"
                                        minWidth: height
                                        onClicked: {
                                            address_input.text = address
                                            editing_address = global_edit_in_progress = true
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
                                            editing_address = global_edit_in_progress = false
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
                                            global_edit_in_progress = false
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
