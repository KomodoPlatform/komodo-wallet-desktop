import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Constants"
import "../Components"

//! Wallet information address creation modal
BasicModal {
    id: root

    width: 500

    ModalContent {
        Layout.topMargin: 5
        Layout.fillWidth: true

        title: qsTr("Create a new address")

        DefaultTextField {
            id: contact_new_address_key

            width: 100

            placeholderText: qsTr("Enter the key")

            onTextChanged: {
                const max_length = 50
                if (text.length > max_length)
                    text = text.substring(0, max_length)
            }

            //! Error tooltip when key already exists.
            DefaultTooltip {
                id: key_already_exists_tooltip
                visible: false
                contentItem: DefaultText {
                    text_value: qsTr("This key already exists.")
                }
            }
        }

        DefaultTextField {
            id: contact_new_address_value

            width: 100

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
                text: qsTr("Ok")

                onClicked: {

                    var create_address_result = wallet_info_type_select.currentValue.add_address_entry(contact_new_address_key.text, contact_new_address_value.text);

                    if (create_address_result === true) {
                        root.close();
                        contact_new_address_key.text = "";
                        contact_new_address_value.text = "";
                    }
                    else {
                        key_already_exists_tooltip.visible = true
                    }
                }

                enabled: contact_new_address_key.text.length > 0 && contact_new_address_value.text.length > 0
            }

            DefaultButton {
                text: qsTr("Cancel")

                onClicked: {
                    root.close();
                    contact_new_address_key.text = "";
                    contact_new_address_value.text = "";
                }
            }
        }
    }
}
