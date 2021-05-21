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

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    //spacing: 20

    readonly property var addressbook_pg: API.app.addressbook_pg

    // Page header
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 100

        DefaultText { // Title
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.top: parent.top
            anchors.topMargin: 10

            text_value: qsTr("Address Book")
            font.weight: Font.Medium
            font.pixelSize: Style.textSize3
        }

        DefaultTextField { // Search input
            id: searchbar
            width: 400
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.bottom: parent.bottom
            anchors.topMargin: 10

            Layout.fillWidth: true
            placeholderText: qsTr("Search a contact by name or tags")
            onTextChanged: addressbook_pg.model.proxy.search_exp = text

            Component.onDestruction: addressbook_pg.model.proxy.search_exp = ""
        }

        PrimaryButton { // New Contact Button
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("New Contact")

            onClicked: new_contact_modal.open()
        }
    }

    // Contact List Header
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        HorizontalLine {
            anchors.top: parent.top
            width: parent.width
            color: Style.colorWhite5
        }

        DefaultText {
            id: header_name_column
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            color: Style.colorWhite4
            text: qsTr("Name")
        }

        DefaultText {
            id: header_tags_column
            anchors.left: header_name_column.right
            anchors.leftMargin: 180
            anchors.verticalCenter: parent.verticalCenter
            color: Style.colorWhite4
            text: qsTr("Tags (first 6)")
        }

        DefaultText {
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.138
            anchors.verticalCenter: parent.verticalCenter
            color: Style.colorWhite4
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

        model: addressbook_pg.model.proxy

        // Contact Card
        delegate: AnimatedRectangle {
            id: contact_card

            property var contact: modelData

            color: Qt.lighter(index % 2 == 0 ? Style.colorTheme6 : Style.colorTheme7, 1.0)
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
