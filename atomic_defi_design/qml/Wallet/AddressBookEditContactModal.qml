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

    onClosed: modelData.reload()

    function trySend(wallet_type, address) {
        // Checks if the selected wallet type is a coin type instead of a ticker.
        if (wallet_type === "QRC-20" || wallet_type === "ERC-20" || wallet_type === "Smart Chain") {
            send_selector.coin_type = wallet_type
            send_selector.address = address
            send_selector.open()
        }

        // Checks if the coin is currently enabled.
        else if (!API.app.portfolio_pg.is_coin_enabled(wallet_type)) {
            enable_coin_modal.coin_name = wallet_type
            enable_coin_modal.open()
        }

        // Checks if the coin has balance.
        else if (parseFloat(API.app.get_balance(wallet_type)) === 0) {
            cannot_send_modal.open()
        }

        // If the coin has balance and is enabled, opens the send modal.
        else {
            API.app.wallet_pg.ticker = wallet_type
            send_modal.address = address
            send_modal.open()
        }
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
            DefaultButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                text: qsTr("Change of wallet type. Current: ") + wallet_type_list_modal.selected_wallet_type
                onClicked: wallet_type_list_modal.open()
            }

            //! Wallet information edition
            TableView {
                id: wallet_info_table

                enabled: wallet_type_list_modal.selected_wallet_type !== ""

                model: modelData.get_addresses(wallet_type_list_modal.selected_wallet_type)

                Layout.topMargin: 15
                Layout.fillWidth: true

                backgroundVisible: false

                headerDelegate: DefaultRectangle {}

                rowDelegate: DefaultRectangle {
                    height: 35
                    radius: 0
                    color: styleData.selected ? Style.colorBlue : styleData.alternate ? Style.colorRectangle : Style.colorRectangleBorderGradient2
                }

                TableViewColumn { //! Key column
                    width: 200

                    role: "key"
                    title: "Key"

                    delegate: RowLayout {
                        DefaultText {
                            Layout.leftMargin: 3
                            text: styleData.row >= 0 ? styleData.value : ""
                            font.pixelSize: Style.textSizeSmall3
                        }

                        VerticalLine {
                            Layout.alignment: Qt.AlignRight
                            Layout.fillHeight: true
                        }
                    }
                }

                TableViewColumn { //! Address column
                    width: 380

                    role: "value"
                    title: "Address"

                    delegate: RowLayout {
                        DefaultText {
                            Layout.leftMargin: 3
                            text: styleData.row >= 0 ? styleData.value : ""
                            font.pixelSize: Style.textSizeSmall3
                        }

                        VerticalLine {
                            Layout.alignment: Qt.AlignRight
                            Layout.fillHeight: true
                        }
                    }
                }

                TableViewColumn { // Buttons column
                    width: 60
                    role: "value"
                    title: "Address"

                    delegate: Row {
                        spacing: 0

                        Qaterial.OutlineButton { //! Copy clipboard button
                            implicitHeight: 35
                            implicitWidth: 35

                            outlined: false

                            icon.source: Qaterial.Icons.contentCopy
                            icon.color: Style.colorWhite1

                            onClicked: {
                                API.qt_utilities.copy_text_to_clipboard(styleData.value)
                            }
                        }

                        Qaterial.OutlineButton { //! Send button
                            implicitHeight: 35
                            implicitWidth: 35

                            outlined: false

                            icon.source: Qaterial.Icons.send
                            icon.color: Style.colorWhite1

                            onClicked: trySend(wallet_type_list_modal.selected_wallet_type, styleData.value)
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

                    enabled: wallet_type_list_modal.selected_wallet_type !== ""
                }

                //! Wallet address deletion
                DangerButton {
                    text: qsTr("Remove")

                    onClicked: {
                        if (wallet_info_table.currentRow >= 0) {
                            wallet_info_table.model.remove_address_entry(wallet_info_table.currentRow)
                        }
                    }

                    enabled: wallet_type_list_modal.selected_wallet_type !== ""
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

        //! Wallets type list modal
        ModalLoader {
            id: wallet_type_list_modal

            property string selected_wallet_type: ""

            sourceComponent: AddressBookWalletTypeListModal {
                selected_wallet_type: ""
                onSelected_wallet_typeChanged: wallet_type_list_modal.selected_wallet_type = selected_wallet_type
            }
        }

        //! Enable coin modal
        ModalLoader {
            property string coin_name

            id: enable_coin_modal

            sourceComponent: BasicModal {
                ModalContent {
                    Layout.fillWidth: true
                    title: qsTr("Enable " + coin_name)

                    DefaultText {
                        text: qsTr("The selected address belongs to a disabled coin, you need to enabled it before sending.")
                    }

                    Row {
                        //! Enable button
                        PrimaryButton {
                            text: qsTr("Enable")

                            onClicked: {
                                API.app.enable_coin(coin_name)
                                enable_coin_modal.close()
                            }
                        }

                        //! Cancel button
                        DefaultButton {
                            Layout.rightMargin: 5
                            text: qsTr("Cancel")

                            onClicked: enable_coin_modal.close()
                        }
                    }
                }
            }
        }

        //! Send selector modal
        ModalLoader {
            id: send_selector

            property string coin_type
            property string address

            onLoaded: {
                item.coin_type = coin_type
                item.address = address
            }

            sourceComponent: AddressBookSendWalletSelector {}
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
