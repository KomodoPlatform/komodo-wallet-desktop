//! Qt
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! Deps
import Qaterial 1.0 as Qaterial

//! Project
import "../Components"
import "../Constants"

BasicModal {
    id: root
    width: 500

    ModalContent {
        Layout.topMargin: 5
        Layout.fillWidth: true

        title: qsTr("Edit contact")

        TextFieldWithTitle {
            id: name_input
            width: 30
            title: qsTr("Contact Name")
            field.placeholderText: qsTr("Enter a contact name")
            field.text: modelData.name
            field.onTextChanged: {
                const max_length = 50
                if (field.text.length > max_length)
                    field.text = field.text.substring(0, max_length)
            }
        }

        //! Wallets info section
        ModalContent {
            title: qsTr("Wallets Information")

            DefaultComboBox {
                id: wallets_info_control

                Layout.alignment: Qt.AlignHCenter
            }
        }

        //! Categories section
        ModalContent {
            title: qsTr("Tags")

            //! Category adding form
            AddressBookNewContactCategory {
                id: add_category
            }

            //! Category adding form opening button
            PrimaryButton {
                text: qsTr("Add tag")

                onClicked: {
                    add_category.open();
                }
            }

            RowLayout {
                Repeater {
                    id: category_repeater
                    model: modelData.categories

                    property var contactModel: modelData

                        Qaterial.OutlineButton {
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 4

                            text: modelData
                            icon.source: Qaterial.Icons.closeOctagon

                            onClicked: {
                                category_repeater.contactModel.remove_category(modelData);
                            }

                            Component.onCompleted: {
                                category_repeater.currentLayoutLeftMargin += 5;
                                category_repeater.width = width;
                            }
                        }
                }
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        //! Validate contact changes and cancel buttons
        RowLayout {
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Layout.rightMargin: 15

            //! Validate
            PrimaryButton {
                text: qsTr("Validate")
                onClicked: {
                    modelData.name = name_input.field.text
                    modelData.save_contact();
                    root.close();
                }
            }

            //! Cancel
            DefaultButton {
                text: qsTr("Cancel")
                onClicked: {
                    root.close()
                }
            }
        }
    }
}
