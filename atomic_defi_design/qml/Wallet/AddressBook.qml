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

    readonly property var page_api: API.app.addressbook_pg

    //! This variable represents a margin size.
    readonly property int layout_margin: 30

    function reset() {

    }

    //! Page header
    RowLayout {
        Layout.topMargin: layout_margin
        Layout.leftMargin: layout_margin
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
            Layout.rightMargin: layout_margin
            Layout.alignment: Qt.AlignRight
            text: qsTr("New Contact")

            onClicked: {
                addressbook_new_contact.open()
            }
        }
    }

    HorizontalLine {
        Layout.fillWidth: true
    }

    //! Contact list
    DefaultListView {
        id: contact_list
        Layout.fillWidth: true
        Layout.fillHeight: true

        model: page_api.addressbook_model.addressbook_proxy_mdl

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
                target: address_book
            }

            FloatingBackground {
                id: background
                width: parent.width - 2 * layout_margin
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
                            Layout.rightMargin: layout_margin

                            //! `Edit` button
                            PrimaryButton {
                                Layout.rightMargin: 1
                                text: qsTr("Edit")
                                font.pixelSize: Style.textSizeSmall3

                                onClicked: {
                                    addressbook_edit_contact.open();
                                }
                            }

                            //! `Delete` button
                            DangerButton {
                                Layout.rightMargin: 1
                                text: qsTr("Remove")
                                font.pixelSize: Style.textSizeSmall3

                                onClicked: {
                                    page_api.remove_contact(index)
                                }
                            }
                        }
                    }
                }

                HorizontalLine {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
