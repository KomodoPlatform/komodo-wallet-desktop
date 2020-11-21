import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"

BasicModal {
    id: root
    width: 500

    ModalContent {
        Layout.topMargin: 5
        Layout.fillWidth: true
        Layout.leftMargin: 15

        title: qsTr("Choose a contact name")

        //! Contact name input.
        DefaultTextField {
            id: name_input
            Layout.topMargin: 20
            Layout.leftMargin: 5
            placeholderText: qsTr("Enter the contact name")
            width: 150
            onTextChanged: {
                const max_length = 50
                if(text.length > max_length)
                    text = text.substring(0, max_length)
            }

            //! Error tooltip when contact name already exists.
            DefaultTooltip {
                id: contact_alrady_exists_tooltip
                visible: false
                contentItem: DefaultText {
                    text_value: qsTr("This contact name already exists.")
                }
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        //! Footer
        RowLayout {
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Layout.bottomMargin: 5

            //! Cancel button.
            DefaultButton {
                text: qsTr("Cancel")

                onClicked: {
                    root.close()
                }
            }

            //! Validate button.
            PrimaryButton {
                text: qsTr("Validate")

                onClicked: {
                    if (name_input.text.length == 0)
                    {
                        return;
                    }

                    var create_contact_result = addressbook.page_api.add_contact(name_input.text.toString());

                    if (create_contact_result === false)
                    {
                        contact_alrady_exists_tooltip.visible = true;
                    }
                    else
                    {
                        root.close();
                    }
                }
            }
        }
    }
}
