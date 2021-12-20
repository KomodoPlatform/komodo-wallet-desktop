// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

// Deps Imports
import Qaterial 1.0 as Qaterial

// Project Imports
import "../Components"
import "../Constants"
import App 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    //spacing: 20

    Layout.rightMargin: 10
    Layout.leftMargin: 10
    readonly property var addressbook_pg: API.app.addressbook_pg

    // Page header
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 80


        DexLabel { // Title
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left 
            anchors.leftMargin: 10
            text_value: qsTr("Address Book")
            font: DexTypo.head6
        }

        DexGradientAppButton {
            
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            iconSource: Qaterial.Icons.textBoxPlus
            radius: 40
            leftPadding: 5
            rightPadding: 5
            padding: 16
            text: qsTr("New Contact")
            onClicked: new_contact_modal.open()
        }
    }

    Item {
        Layout.fillWidth: true 
        Layout.preferredHeight: 60
        DexRectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 300
            opacity: enabled ? 1 : .5
            height: 50
            radius: 20
            x: 10
            color: DexTheme.contentColorTop
            DefaultTextField {
                id: searchbar
                anchors.fill: parent
                anchors.margins: 2
                function reset() {
                    searchbar.text = ""
                }
                Qaterial.Icon {
                    icon: Qaterial.Icons.magnify
                    color: searchbar.color
                    anchors.verticalCenter: parent.verticalCenter
                    x: 5
                }
                leftPadding: 40
                placeholderText: qsTr("Search a contact by name or tags")

                font: DexTypo.body2
                onTextChanged: addressbook_pg.model.proxy.search_exp = text
                Component.onDestruction: addressbook_pg.model.proxy.search_exp = ""
                background: null
            }
        }
    }

    // Contact List Header
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.rightMargin: 10
        Layout.leftMargin: 10


        DexLabel {
            id: header_name_column
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            text: qsTr("Name")
        }

        DexLabel {
            id: header_tags_column
            anchors.left: header_name_column.right
            anchors.leftMargin: 180
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            text: qsTr("Tags (first 6)")
        }

        DexLabel {
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.138
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            text: qsTr("Actions")
        }

        HorizontalLine {
            width: parent.width
            color: Style.colorWhite5
            anchors.bottom: parent.bottom
        }
    }

    // Contact List
    DefaultListView {
        id: contact_list
        Layout.fillWidth: true
        Layout.fillHeight: true

        Layout.rightMargin: 10
        Layout.leftMargin: 10

        model: addressbook_pg.model.proxy

        // Contact Card
        delegate: AnimatedRectangle {
            id: contact_card

            property var contact: modelData

            color: Qt.lighter(index % 2 == 0 ?  DexTheme.backgroundColor : DexTheme.surfaceColor, 1.0)
            width: root.width
            height: 55

            DefaultText { // Contact Name
                id: contact_name
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                width: 160

                text: modelData.name
                elide: Text.ElideRight
            }

            VerticalLine {
                anchors.left: contact_name.right
                anchors.leftMargin: 25
                height: parent.height
                width: 1
            }

            Flow { // Contact First 6 Tags
                id: contact_tags_list
                flow: GridLayout.LeftToRight

                readonly property int length: 6           // Number of displayed tags
                readonly property int tagButtonWidth: 150 // Width of a tag button

                width: length * tagButtonWidth

                anchors.left: contact_name.right
                anchors.leftMargin: 50
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: contact_card.contact.categories

                    delegate: Qaterial.OutlineButton {
                        width: contact_tags_list.tagButtonWidth
                        visible: index < contact_tags_list.length && index < contact_card.contact.categories.length
                        outlined: false
                        text: modelData
                        icon.source: Qaterial.Icons.tag
                        //elide: Text.ElideRight

                        onClicked: searchbar.text = modelData
                    }
                }
            }

            VerticalLine {
                anchors.right: edit_contact_button.left
                anchors.rightMargin: 30
                height: parent.height
                width: 1
            }

            DefaultButton { // Edit Button
                id: edit_contact_button

                anchors.right: remove_contact_button.left
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Edit")
                font.pixelSize: Style.textSizeSmall3
                width: 120

                onClicked: {
                    edit_contact_modal.contactModel = modelData
                    edit_contact_modal.open()
                }
            }

            DangerButton { // Remove Button
                id: remove_contact_button

                anchors.right: parent.right
                anchors.rightMargin: 30
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Remove")
                font.pixelSize: Style.textSizeSmall3
                width: 120

                onClicked: {
                    remove_contact_modal.contactName = modelData.name
                    remove_contact_modal.open()
                }
            }
        }


        // Create Contact Modal
        ModalLoader {
            id: new_contact_modal
            sourceComponent: AddressBookNewContactModal {}
        }

        // Edit Contact Modal
        ModalLoader {
            id: edit_contact_modal

            property var contactModel

            onLoaded: item.contactModel = contactModel

            sourceComponent: AddressBookEditContactModal {}
        }

        // Delete Contact Modal
        ModalLoader {
            property string contactName

            id: remove_contact_modal

            sourceComponent: BasicModal {
                width: 500

                ModalContent {
                    Layout.fillWidth: true
                    title: qsTr("Do you want to remove this contact ?")

                    RowLayout {
                        DangerButton {
                            text: qsTr("Yes")

                            onClicked: {
                                remove_contact_modal.close()
                                addressbook_pg.model.remove_contact(contactName)
                            }
                        }

                        DefaultButton {
                            text: qsTr("No")

                            onClicked: remove_contact_modal.close()
                        }
                    }
                }
            }
        }
    }
}
