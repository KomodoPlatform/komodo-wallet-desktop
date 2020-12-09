import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"

//! New category form
BasicModal {
    id: root
    width: 500

    ModalContent {
        Layout.topMargin: 5
        Layout.fillWidth: true

        //! Category name input.
        DefaultTextField {
            id: name_input
            Layout.topMargin: 4
            Layout.leftMargin: 20
            placeholderText: qsTr("Enter the tag name")
            width: 150
            onTextChanged: {
                const max_length = 20
                if(text.length > max_length)
                    text = text.substring(0, max_length)
            }

            //! Error tooltip when category name already exists.
            DefaultTooltip {
                id: alrady_exists_tooltip
                visible: false
                contentItem: DefaultText {
                    text_value: qsTr("This contact already has this tag")
                }
            }
        }

        //! Buttons
        RowLayout {
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Layout.bottomMargin: 5

            //! Add
            PrimaryButton {
                text: qsTr("Add")
                onClicked: {
                    if (!modelData.add_category(name_input.text))
                    {
                        alrady_exists_tooltip.visible = true
                    }
                    else
                    {
                        name_input.text = ""
                        add_category_modal.close()
                    }
                }
            }

            //! Cancel
            DefaultButton {
                text: qsTr("Cancel")
                onClicked: {
                    name_input.text = ""
                    add_category_modal.close()
                }
            }
        }
    }
}
