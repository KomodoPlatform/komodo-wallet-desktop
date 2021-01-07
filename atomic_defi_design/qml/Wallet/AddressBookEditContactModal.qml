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
    width: 700

    onClosed: {
        modelData.reload()
        wallet_info_type_select.currentIndex = 0
    }

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

                headerDelegate: DefaultRectangle {}

                rowDelegate: DefaultRectangle {
                    height: 35
                    radius: 0
                    color: styleData.selected ? Style.colorBlue : styleData.alternate ? Style.colorRectangle : Style.colorRectangleBorderGradient2
                }

                //! Key column
                TableViewColumn {
                    width: 200

                    role: "key"
                    title: "Key"

                    delegate: RowLayout {
                        DefaultText {
                            text: styleData.row >= 0 ? styleData.value : ""
                            font.pixelSize: Style.textSizeSmall3
                        }

                        VerticalLine {
                            Layout.fillHeight: true
                        }
                    }
                }
                //! Address column
                TableViewColumn {
                    width: 380

                    role: "value"
                    title: "Address"

                    delegate: RowLayout {
                        //! Text value
                        DefaultText {
                            text: styleData.row >= 0 ? styleData.value : ""
                            font.pixelSize: Style.textSizeSmall3
                        }

                        VerticalLine {
                            Layout.fillHeight: true
                        }
                    }
                }
                // Buttons column
                TableViewColumn {
                    role: "value"
                    title: "Address"

                    delegate: Row {
                        spacing: 0

                        //! Copy clipboard button
                        Qaterial.OutlineButton {
                            implicitHeight: 35
                            implicitWidth: 35

                            outlined: false

                            icon.source: Qaterial.Icons.contentCopy
                            icon.color: Style.colorWhite1

                            onClicked: {
                                API.qt_utilities.copy_text_to_clipboard(styleData.value)
                            }
                        }

                        //! Send button
                        Qaterial.OutlineButton {
                            implicitHeight: 35
                            implicitWidth: 35

                            outlined: false

                            icon.source: Qaterial.Icons.send
                            icon.color: Style.colorWhite1

                            onClicked: {
                                if (!API.app.portfolio_pg.is_coin_enabled(wallet_info_type_select.currentValue.type)) {
                                    enable_coin_modal.coin_name = wallet_info_type_select.currentValue.type
                                    enable_coin_modal.open()
                                }
                                else if (parseFloat(API.app.get_balance(wallet_info_type_select.currentValue.type)) === 0) {
                                    cannot_send_modal.open()
                                }
                                else {
                                    API.app.wallet_pg.ticker = wallet_info_type_select.currentValue.type
                                    send_modal.address = styleData.value
                                    send_modal.open()
                                }
                            }
                        }
                    }
                }
            }

            //! Wallet information buttons
            RowLayout {
                //! Wallet address creation
                PrimaryButton {
                    text: qsTr("Add")

                    onClicked: wallet_info_address_creation_modal.open();
                }

                //! Wallet address deletion
                DangerButton {
                    text: qsTr("Remove")

                    onClicked: {
                        if (wallet_info_table.currentRow >= 0) {
                            wallet_info_type_select.currentValue.remove_address_entry(wallet_info_table.currentRow)
                        }
                    }
                }
            }

            ModalLoader {
                id: wallet_info_address_creation_modal
                sourceComponent: AddressBookAddContactAddressModal {}
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
        ModalLoader {
            id: add_category_modal
            sourceComponent: AddressBookNewContactCategoryModal {}
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

                onClicked: add_category_modal.open()
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
                    modelData.save()
                    root.close();
                }
            }

            //! Cancel
            DefaultButton {
                text: qsTr("Cancel")
                onClicked: root.close()
            }
        }

        //! Enable coin modal
        ModalLoader {
            property string coin_name

            id: enable_coin_modal

            sourceComponent: BasicModal {
                width: 400

                ModalContent {
                    Layout.fillWidth: true
                    title: qsTr("Enable coin")

                    DefaultText {
                        text: qsTr("The selected address belongs to a disabled coin, you need to enabled it before sending.")
                    }

                    //! Enable button
                    PrimaryButton {
                        text: qsTr("Enable")

                        onClicked: {
                            API.app.enable_coin(coin_name)
                            enable_coin_modal.close()
                        }
                    }

                    //! Disable button
                    DefaultButton {
                        text: qsTr("Cancel")

                        onClicked: root.close()
                    }
                }
            }
        }

        //! Send modal
        ModalLoader {
            property string address

            id: send_modal

            onLoaded: item.address_field.text = address

            sourceComponent: SendModal {
                address_field.enabled: false
            }
        }

        //! Cannot send modal
        ModalLoader {
            id: cannot_send_modal

            sourceComponent: BasicModal {
                ModalContent {
                    title: qsTr("Cannot send to this address")

                    DefaultText {
                        text: qsTr("Your balance is empty")
                    }

                    DefaultButton {
                        text: qsTr("Ok")

                        onClicked: cannot_send_modal.close()
                    }
                }
            }
        }
    }
}
