import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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
        ModalContent {
            title: qsTr("Contact Name")

            //! Contact name input.
            DefaultTextField {
                id: name_input
                placeholderText: qsTr("Enter a contact name")
                text: modelData.name
                width: 150
                onTextChanged: {
                    const max_length = 50
                    if(text.length > max_length)
                        text = text.substring(0, max_length)
                }
            }
        }

        //! Wallets info section
        ModalContent {
            title: qsTr("Wallets Information")

            DefaultComboBox {
                id: wallets_info_control

                Layout.alignment: Qt.AlignHCenter

                mainBorderColor: Style.getCoinColor(ticker)
            }
        }

        //! Categories section
        ModalContent {
            title: qsTr("Tags")

            //! New category form opening button
            PrimaryButton {
                text: qsTr("Add tag")

                onClicked: {
                    add_category.open();
                }
            }

            RowLayout {
                Repeater {
                    model: modelData.categories

                    FloatingBackground {
                        width: category_name.width
                        height: category_name.font.pixelSize + 5
                        Layout.leftMargin: 5

                        DefaultText {
                            id: category_name
                            text: modelData
                            color: Style.colorText
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }

        //! New category form
        BasicModal {
            id: add_category

            enabled: false
            visible: false
        }


        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        //! Buttons
        RowLayout {
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Layout.rightMargin: 15

            //! Validate
            PrimaryButton {
                text: qsTr("Validate")
                onClicked: {
                    modelData.name = name_input.text
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
