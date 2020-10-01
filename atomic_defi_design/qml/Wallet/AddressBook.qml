import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"


ColumnLayout {
    id: address_book

    property bool global_edit_in_progress: false
    Layout.fillWidth: true

    property bool initialized: false
    property bool inCurrentPage: wallet.inCurrentPage() && main_layout.currentIndex === 1

    onInCurrentPageChanged: {
        if(inCurrentPage) {
            initialized = true
        }
        // Clean-up if user leaves this page
        else {
            if(initialized) {
                console.log("Cleaning up the empty items at address book...")
                global_edit_in_progress = false
            }
            // Open main wallet page
            if(main_layout.currentIndex === 1)
                closeAddressBook()
        }
    }

    readonly property var essential_coins: General.all_coins.filter(c => {
                    if(c.type === "ERC-20" && c.ticker !== "ETH") return false
                    else if(c.type === "QRC-20" && c.ticker !== "QTUM") return false
                    else if(c.type === "Smart Chain" && c.ticker !== "KMD") return false

                    return true
                })

    spacing: 20

    DefaultText {
        id: back_button
        property bool disabled: global_edit_in_progress
        Layout.leftMargin: layout_margin
        text_value: API.app.settings_pg.empty_string + ("< " + qsTr("Back"))
        font.weight: Font.Bold
        color: disabled ? Style.colorTextDisabled : Style.colorText

        DefaultMouseArea {
            anchors.fill: parent
            onClicked: { if(!back_button.disabled) closeAddressBook() }
        }
    }

    RowLayout {
        Layout.leftMargin: layout_margin
        Layout.fillWidth: true

        DefaultText {
            text_value: API.app.settings_pg.empty_string + (qsTr("Address Book"))
            font.weight: Font.Bold
            font.pixelSize: Style.textSize3
            Layout.fillWidth: true
        }

        DefaultButton {
            Layout.rightMargin: layout_margin
            Layout.alignment: Qt.AlignRight
            text: API.app.settings_pg.empty_string + (qsTr("New Contact"))
            enabled: !global_edit_in_progress
            onClicked: {
                API.app.addressbook_mdl.add_contact_entry()
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
        model: API.app.addressbook_mdl.addressbook_proxy_mdl

        delegate: Item {
            id: contact
            readonly property int line_height: 200
            readonly property bool is_last_item: index === model.length - 1
            property bool editing: false

            readonly property var selected_coins: modelData.readonly_addresses.map(c => c.type)

            width: list.width
            height: contact_bg.height + layout_margin


            function kill() {
                if(address_book.initialized)
                    API.app.addressbook_mdl.remove_at(index)
            }

            Connections {
                target: address_book

                function onInCurrentPageChanged() {
                    if(!address_book.inCurrentPage) {
                        const addresses_list = modelData.readonly_addresses

                        // No killing if any of the addresses is filled
                        for(const a of addresses_list)
                            if(a.address !== "") {
                                if(contact.editing)
                                    contact.editing = false

                                return
                            }

                        // Kill if all addresses are empty
                        contact.kill()
                    }
                }
            }


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
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.leftMargin: layout_margin

                            DefaultText {
                                Layout.leftMargin: name_input.Layout.leftMargin

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

                                color: Style.colorText
                                placeholderText: API.app.settings_pg.empty_string + (qsTr("Enter the contact name"))
                                width: 150
                                onTextChanged: {
                                    const max_length = 50
                                    if(text.length > max_length)
                                        text = text.substring(0, max_length)
                                }

                                visible: editing
                            }

                            DefaultText {
                                id: edit_contact
                                Layout.leftMargin: layout_margin * 0.25

                                visible: !editing && enabled
                                enabled: !global_edit_in_progress
                                text: "✎"
                                font.weight: Font.Bold
                                color: Style.colorGreen

                                DefaultMouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if(edit_contact.enabled) {
                                            name_input.text = modelData.name
                                            editing = global_edit_in_progress = true
                                        }
                                    }
                                }
                            }
                        }

                        // Buttons
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.rightMargin: layout_margin

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
                                    kill()
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
                            delegate: AnimatedRectangle {
                                id: address_line

                                property bool initialized: false

                                function kill() {
                                    if(address_book.initialized) modelData.remove_at(index)
                                }

                                Connections {
                                    target: address_book

                                    function onInCurrentPageChanged() {
                                        if(address_book.inCurrentPage && !address_line.initialized && address_line.selectable_coins.length === 0) {
                                            address_line.updateSelectableCoins()
                                            address_line.initialized = true
                                        }

                                        if(!address_book.inCurrentPage) {
                                            if(address === "") address_line.kill()
                                            else if(address_line.editing_address) {
                                                address_line.editing_address = false
                                            }
                                        }
                                    }
                                }

                                property bool editing_address: false


                                property var selectable_coins: ([])

                                Connections {
                                    target: contact

                                    function onSelected_coinsChanged() {
                                        address_line.updateSelectableCoins()
                                    }
                                }

                                function updateSelectableCoins() {
                                    const original_text = type

                                    selectable_coins = essential_coins.filter(c => c.ticker === type || contact.selected_coins.indexOf(c.ticker) === -1).map(c => c.ticker)

                                    if(original_text !== "")
                                        combo_base.currentIndex = address_line.selectable_coins.indexOf(original_text)
                                }


                                width: contact_bg.width
                                height: 50


                                color: Style.colorOnlyIf(mouse_area.containsMouse, Style.colorTheme6)

                                DefaultMouseArea {
                                    id: mouse_area
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                                // Edit
                                DefaultText {
                                    id: edit_icon
                                    anchors.left: parent.left
                                    anchors.leftMargin: layout_margin * 0.5
                                    anchors.verticalCenter: parent.verticalCenter

                                    visible: !editing_address && enabled
                                    enabled: !global_edit_in_progress
                                    text: "✎"
                                    font.weight: Font.Bold
                                    color: enabled ? Style.colorGreen : Style.colorTextDisabled

                                    DefaultMouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if(edit_icon.enabled) {
                                                address_input.text = address
                                                editing_address = global_edit_in_progress = true
                                            }
                                        }
                                    }
                                }

                                // Icon
                                DefaultImage {
                                    id: icon

                                    anchors.left: edit_icon.right
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter

                                    source: General.coinIcon(type)
                                    width: Style.textSize2
                                }

                                // Name
                                DefaultText {
                                    anchors.left: combo_base.anchors.left
                                    anchors.leftMargin: combo_base.anchors.leftMargin
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: !combo_base.visible

                                    text_value: API.app.settings_pg.empty_string + (type)
                                }

                                DefaultComboBox {
                                    id: combo_base

                                    anchors.left: icon.right
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 125
                                    visible: editing_address

                                    model: selectable_coins

                                    onCurrentTextChanged: { if(currentText !== type) type = currentText }
                                }

                                VerticalLine {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                }

                                // Address name
                                DefaultText {
                                    anchors.left: combo_base.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin
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
                                    anchors.left: combo_base.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: layout_margin
                                    font.pixelSize: Style.textSizeSmall3
                                    placeholderText: API.app.settings_pg.empty_string + (qsTr("Enter the address"))
                                    width: 400
                                    visible: editing_address
                                }

                                RowLayout {
                                    anchors.right: parent.right
                                    anchors.rightMargin: layout_margin * 0.5
                                    anchors.verticalCenter: parent.verticalCenter

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
                                        text: API.app.settings_pg.empty_string + (qsTr("Explorer"))
                                        enabled: address !== "" && type !== ""
                                        visible: !editing_address
                                        onClicked: General.viewAddressAtExplorer(type, address)
                                    }

                                    DefaultButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.leftMargin: layout_margin

                                        font.pixelSize: Style.textSizeSmall3
                                        text: API.app.settings_pg.empty_string + (qsTr("Send"))
                                        minWidth: height
                                        enabled: address !== "" && type !== "" && API.app.enabled_coins.map(c => c.ticker).indexOf(type) !== -1
                                        visible: !editing_address
                                        onClicked: {
                                            api_wallet_page.ticker = type
                                            closeAddressBook()
                                            send_modal.address_field.text = address
                                            send_modal.open()
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
                                            address_line.kill()
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
