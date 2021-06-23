// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 //> ToolTip

// Project Imports
import "../Constants"
import "../Components"

// Contact address entry creation/edition modal
BasicModal {
    id: root

    property var contactModel

    // Address Creation (false) or Edition (true) mode.
    property bool isEdition: false

    property alias walletType: wallet_type_list_modal.selected_wallet_type // The selected wallet type that will be associated this new address entry.
    property alias key: contact_new_address_key.text                       // The entered key that will be associated to this new address entry.
    property alias value: contact_new_address_value.text                   // The entered address value that will be associated to this new address entry.

    // These properties are required in edition mode since we need to wipe out old address entry.
    property string oldWalletType
    property string oldKey
    property string oldValue

    width: 400

    ModalContent {
        Layout.topMargin: 5
        Layout.fillWidth: true

        title: isEdition ? qsTr("Edit address entry") : qsTr("Create a new address")

        // Wallet Type Selector
        DexButton
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            onClicked: wallet_type_list_modal.open()

            DexLabel
            {
                anchors.centerIn: parent

                width: 320

                elide: Text.ElideRight
                wrapMode: Text.NoWrap

                font: parent.font
                text: qsTr("Selected wallet: %1").arg(walletType !== "" ? walletType : qsTr("NONE"))

                ToolTip.text: text
                ToolTip.visible: parent.containsMouse
            }
        }

        // Address Key Field
        DefaultTextField {
            id: contact_new_address_key

            Layout.topMargin: 5
            implicitWidth: parent.width

            placeholderText: qsTr("Enter a name")

            onTextChanged: {
                const max_length = 30
                if (text.length > max_length)
                    text = text.substring(0, max_length)
            }

            // Error tooltip when key already exists.
            DefaultTooltip {
                id: key_already_exists_tooltip
                visible: false
                contentItem: DefaultText {
                    text_value: qsTr("This key already exists.")
                }
            }
        }

        // Address Value Field
        DefaultTextField {
            id: contact_new_address_value

            Layout.topMargin: 5
            implicitWidth: parent.width

            placeholderText: qsTr("Enter the address")

            onTextChanged: {
                const max_length = 50
                if (text.length > max_length)
                    text = text.substring(0, max_length)
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        RowLayout {
            PrimaryButton {
                text: qsTr("Validate")

                onClicked: {
                    if (isEdition) { // Removes old address entry before if we are in edition mode.
                        console.debug("AddressBook: Replacing address %1:%2:%3 of contact %4"
                                        .arg(oldWalletType).arg(oldKey).arg(oldValue).arg(contactModel.name))
                        contactModel.remove_address_entry(oldWalletType, oldKey);
                    }

                    var create_address_result = contactModel.add_address_entry(walletType, key, value);
                    if (create_address_result === true) {
                        console.debug("AddressBook: Address %1:%2:%3 created for contact %4"
                                        .arg(walletType).arg(key).arg(value).arg(contactModel.name))
                        root.close()
                    }
                    else {
                        console.debug("AddressBook: Failed to create address for contact %1: %2 key already exists"
                                        .arg(contactModel.name).arg(key))
                        key_already_exists_tooltip.visible = true
                    }
                }

                enabled: key.length > 0 && value.length > 0 && walletType !== ""
            }

            DefaultButton {
                text: qsTr("Cancel")

                onClicked: root.close()
            }
        }


        ModalLoader {
            id: wallet_type_list_modal

            property string selected_wallet_type: ""

            sourceComponent: AddressBookWalletTypeListModal
            {
                onSelected_wallet_typeChanged: wallet_type_list_modal.selected_wallet_type = selected_wallet_type
            }
        }
    }
}
