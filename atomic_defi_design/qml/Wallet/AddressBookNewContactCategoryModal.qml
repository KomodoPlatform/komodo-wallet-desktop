import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

//! New category form
BasicModal {
    id: root
    width: 500

    property var contactModel

    ModalContent {
        Layout.fillWidth: true
        title: qsTr("Add a new tag")

        RowLayout {
            //! Category name input.
            DefaultTextField {
                id: name_input
                placeholderText: qsTr("Enter the tag name")
                onTextChanged: {
                    const max_length = 14
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

            //! Add
            PrimaryButton {
                Layout.leftMargin: 90
                text: qsTr("Add")
                onClicked: {
                    if (!contactModel.add_category(name_input.text))
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
