import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../Components"
import "../Constants"


ColumnLayout {
    id: addressbook
    Layout.fillWidth: true
    spacing: 20

    readonly property var page: API.app.addressbook_pg

    //! Page header
    RowLayout {
        Layout.topMargin: 30
        Layout.leftMargin: 30
        Layout.fillWidth: true

        //! Title.
        DefaultText {
            text_value: qsTr("Address Book")
            font.weight: Font.Medium
            font.pixelSize: Style.textSize3
            Layout.fillWidth: true
        }

        //! Button to add contact
        PrimaryButton {
            Layout.rightMargin: 30
            Layout.alignment: Qt.AlignRight
            text: qsTr("New Contact")

            onClicked: new_contact_modal.open()
        }
    }

    HorizontalLine {
        Layout.fillWidth: true
    }

    // Search input
    DefaultTextField {
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
            property var item_margin: 5     //! Margin between each card.
            property var height_shift: 2
            property var current_height: 50

            id: contact_card
            height: current_height + item_margin
            width: contact_list.width

            // Increases the height each time a contact card is created.
            Component.onCompleted: {
                current_height += height_shift
            }

            Connections {
                target: addressbook
            }

            FloatingBackground {
                id: background
                width: parent.width - 2 * 30
                height: column_layout.height
                anchors.centerIn: parent

                ColumnLayout {
                    id: column_layout
                    width: parent.width
                    anchors.centerIn: parent

                    RowLayout {
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: 50
                        Layout.alignment: Qt.AlignVCenter

                        //! Contact name
                        DefaultText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.leftMargin: 20

                            text: modelData.name
                            color: Style.colorText
                            visible: true
                        }

                        //! Buttons
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.rightMargin: 30

                            //! `Edit` button
                            PrimaryButton {
                                Layout.rightMargin: 1
                                text: qsTr("Edit")
                                font.pixelSize: Style.textSizeSmall3

                                onClicked: edit_contact_modal.open()
                            }

                            //! `Delete` button
                            DangerButton {
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
