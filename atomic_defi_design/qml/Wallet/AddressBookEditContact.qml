//! Qt
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

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

        //! Contact name section
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

        //! Wallets information
        ColumnLayout {
            Layout.fillWidth: true

            //! Title
            TitleText {
                text: qsTr("Wallets Information")
            }

            //! Wallets information type selection list
            DefaultComboBox {
                id: wallet_info_type_select

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                model: modelData
                textRole: "type"
                mainLineText: currentValue.type
            }

            //! Wallet information edition
            TableView {
                id: wallet_info_table
                model: wallet_info_type_select.currentValue

                Layout.topMargin: 15
                Layout.fillWidth: true

                backgroundVisible: false

                headerDelegate: DefaultRectangle {
                }

                rowDelegate: DefaultRectangle {
                    id: wallet_info_row_rect

                    radius: 0
                    color: styleData.alternate ? Style.colorRectangle : Style.colorRectangleBorderGradient2
                }

                itemDelegate: Item {
                    DefaultText {
                        Layout.alignment: Qt.AlignVCenter
                        text: styleData.value
                        font.pixelSize: Style.textSizeSmall4
                        width: styleData.column === 0 ? wallet_info_key_column.width : wallet_info_value_column.width
                        height: wallet_info_row_rect.implicitHeight
                    }
                }

                //! Key column
                TableViewColumn {
                    id: wallet_info_key_column

                    role: "key"
                    title: "Key"
                    width: 200
                }
                //! Address column
                TableViewColumn {
                    id: wallet_info_value_column

                    role: "value"
                    title: "Address"
                }
            }

            //! Wallet information buttons
            RowLayout {
                //! Wallet address creation
                PrimaryButton {
                    text: qsTr("Add")

                    onClicked: {
                        wallet_info_address_creation.open();
                    }
                }

                //! Wallet address deletion
                DangerButton {
                    text: qsTr("Remove")

                    onClicked: {
                        modelData[wallet_info_type_select.currentIndex].remove_address_entry(wallet_info_table.currentRow)
                    }
                }
            }

            //! Wallet information address creation modal
            BasicModal {
                id: wallet_info_address_creation

                width: 400

                ModalContent {
                    Layout.topMargin: 5
                    Layout.fillWidth: true

                    title: qsTr("Add new address")

                    TextFieldWithTitle {
                        id: contact_new_address_key

                        title: qsTr("Key")

                        field.onTextChanged: {
                            const max_length = 50
                            if (field.text.length > max_length)
                                field.text = field.text.substring(0, max_length)
                        }
                    }

                    TextFieldWithTitle {
                        id: contact_new_address_value

                        Layout.fillWidth: true

                        title: qsTr("Value")

                        field.onTextChanged: {
                            const max_length = 50
                            if (field.text.length > max_length)
                                field.text = field.text.substring(0, max_length)
                        }
                    }

                    HorizontalLine {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        PrimaryButton {
                            text: qsTr("Ok")

                            onClicked: {
                                wallet_info_address_creation.close();
                                modelData[wallet_info_type_select.currentIndex].add_address_entry(contact_new_address_key.field.text, contact_new_address_value.field.text)
                                contact_new_address_key.field.text = "";
                                contact_new_address_value.field.text = "";
                            }
                        }

                        DefaultButton {
                            text: qsTr("Cancel")

                            onClicked: {
                                contact_new_address_key.field.text = "";
                                contact_new_address_value.field.text = "";
                                wallet_info_address_creation.close();
                            }
                        }
                    }
                }
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        //! Categories section title
        TitleText {
            text: qsTr("Tags")
        }

        //! Category adding form
        AddressBookNewContactCategory {
            id: add_category
        }

        //! Categories list
        Flow {
            Layout.fillWidth: true

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
                }
            }


            //! Category adding form opening button
            Qaterial.OutlineButton {
                Layout.leftMargin: 10

                text: qsTr("+")

                onClicked: {
                    add_category.open();
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
                    modelData.save();
                    root.close();
                }
            }

            //! Cancel
            DefaultButton {
                text: qsTr("Cancel")
                onClicked: {
                    name_input.field.text = modelData.name
                    modelData.reset();
                    root.close();
                }
            }
        }
    }
}
