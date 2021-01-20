//! Qt
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

//! Deps
import Qaterial 1.0 as Qaterial

//! Project
import "../Components"
import "../Constants"

ColumnLayout {
    id: addressbook
    Layout.fillWidth: true
    spacing: 20

    readonly property var page: API.app.addressbook_pg

    // Page header
    RowLayout {
        Layout.topMargin: 30
        Layout.leftMargin: 30
        Layout.fillWidth: true

        DefaultText { // Title
            text_value: qsTr("Address Book")
            font.weight: Font.Medium
            font.pixelSize: Style.textSize3
            Layout.fillWidth: true
        }

        PrimaryButton { // New Contact Button
            Layout.rightMargin: 30
            Layout.alignment: Qt.AlignRight
            text: qsTr("New Contact")

            onClicked: new_contact_modal.open()
        }
    }

    HorizontalLine {
        Layout.fillWidth: true
    }


    DefaultTextField { // Search input
        id: searchbar

        Layout.leftMargin: 30
        Layout.rightMargin: 900
        Layout.fillWidth: true
        placeholderText: qsTr("Search a contact by name or tags")
        onTextChanged: page.model.proxy.search_exp = text

        Component.onDestruction: page.model.proxy.search_exp = ""
    }

    //! Contact list
    DefaultListView {
        id: contact_list
        Layout.fillWidth: true
        Layout.fillHeight: true

        model: page.model.proxy

        //! Contact card
        delegate: Item {
            id: contact_card

            readonly property int item_margin: 5     // Margin between each card.
            readonly property int height_shift: 2
            property int current_height: 50

            readonly property var contact: modelData

            height: current_height + item_margin
            width: contact_list.width

            // Increases current y position each time a contact card is created.
            Component.onCompleted: current_height += height_shift

            Connections {
                target: addressbook
            }

            FloatingBackground {
                id: background
                width: parent.width - 2 * 18
                height: 50
                anchors.centerIn: parent

                RowLayout {
                    Layout.preferredHeight: parent.height
                    DefaultText { // Show Contact Name
                        Layout.leftMargin: 20
                        Layout.preferredWidth: 120

                        text: modelData.name
                        color: Style.colorText
                        elide: Text.ElideRight
                    }

                    VerticalLine {
                        Layout.alignment: Qt.AlignRight
                        Layout.fillHeight: true
                    }

                    RowLayout { // Tags Row
                        id: tags_row_layout

                        readonly property int tag_column_width: 164
                        readonly property int tag_column_nb: 5

                        Layout.preferredWidth: tag_column_width * tag_column_nb + 5

                        Flow {
                            Repeater {    // Contact tags, display 5 maximum.
                                model: 5
                                delegate: ColumnLayout {
                                    Qaterial.OutlineButton {
                                        Layout.preferredWidth: tags_row_layout.tag_column_width
                                        visible: index < contact_card.contact.categories.length

                                        text: contact_card.contact.categories[index]
                                        icon.source: Qaterial.Icons.cardSearchOutline
                                        elide: Text.ElideRight

                                        onClicked: searchbar.text = contact_card.contact.categories[index]
                                    }
                                }
                            }
                        }
                    }

                    VerticalLine {
                        Layout.fillHeight: true
                    }

                    RowLayout {    // Edit Or Remove Contact
                        Layout.leftMargin: 8
                        PrimaryButton { // Edit Button
                            text: qsTr("Edit")
                            font.pixelSize: Style.textSizeSmall3

                            onClicked: edit_contact_modal.open()
                        }
                        DangerButton { // Remove Button
                            Layout.rightMargin: 1
                            text: qsTr("Remove")
                            font.pixelSize: Style.textSizeSmall3

                            onClicked: {
                                remove_contact_modal.contactName = modelData.name
                                remove_contact_modal.open()
                            }
                        }
                    }
                }

                HorizontalLine {
                    Layout.fillWidth: true
                }

                ModalLoader {
                    id: edit_contact_modal
                    sourceComponent: AddressBookEditContactModal {}
                }
            }
        }
    }

    //! Panel to create a contact
    ModalLoader {
        id: new_contact_modal
        sourceComponent: AddressBookNewContactModal {}
    }

    //! Panel to delete a contact
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
                            page.model.remove_contact(contactName)
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
