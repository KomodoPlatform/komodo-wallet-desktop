import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2

import "../Components"
import "../Constants"

BasicModal {
    id: root

    width: 700

    onClosed: {
        // reset all
    }

    property var config_fields: ({})

    function prepareConfigs() {
        config_fields = {
             type: input_type.currentText,
             ticker: input_ticker.field.text.toUpperCase(),
             image_path: input_logo.path,
             name: input_name.field.text,
             contract_address: input_contract_address.field.text,
             active: input_active.checked,
             coinpaprika_id : input_coinpaprika_id.field.text
        }
    }

    readonly property bool is_erc20: input_type.currentText === "ERC-20"

    // Type page
    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Choose the coin type"))

        ComboBoxWithTitle {
            id: input_type
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Type"))
            model: ["ERC-20"]//, "QRC-20", "UTXO", "Smart Chain"]
            currentIndex: 0
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.previousPage()
            },

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Next"))
                Layout.fillWidth: true
                onClicked: root.nextPage()
            }
        ]
    }

    // Ticker page
    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Choose the coin ticker"))

        TextFieldWithTitle {
            id: input_ticker
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Ticker"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the ticker"))
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Previous"))
                Layout.fillWidth: true
                onClicked: root.previousPage()
            },

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Next"))
                Layout.fillWidth: true
                enabled: input_ticker.field.text !== ""
                onClicked: root.nextPage()
            }
        ]
    }

    // Logo page
    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Choose the coin logo"))

        DefaultButton {
            Layout.fillWidth: true
            text: API.get().settings_pg.empty_string + (qsTr("Browse") + "...")
            onClicked: input_logo.open()
        }

        FileDialog {
            id: input_logo
            readonly property string path: input_logo.fileUrl.toString()

            title: API.get().settings_pg.empty_string + (qsTr("Please choose the coin logo"))
            folder: shortcuts.home
            selectMultiple: false
            onAccepted: {
                console.log("Image chosen: " + input_logo.path)
            }
            onRejected: {
                console.log("Image choice canceled")
            }

            nameFilters: ["Image files (*.jpg *.png)"]
        }

        DefaultImage {
            Layout.alignment: Qt.AlignHCenter

            //visible: input_logo.path !== ""
            Layout.preferredWidth: 300
            Layout.preferredHeight: Layout.preferredWidth
            source: input_logo.path
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Previous"))
                Layout.fillWidth: true
                onClicked: root.previousPage()
            },

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Next"))
                Layout.fillWidth: true
                enabled: input_logo.path !== ""
                onClicked: root.nextPage()
            }
        ]
    }

    // Configuration
    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Configuration"))

        TextFieldWithTitle {
            id: input_name
            visible: !is_erc20
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Name"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the name"))
        }

        AddressFieldWithTitle {
            id: input_contract_address
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Contract Address"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the contract address"))
        }

        TextFieldWithTitle {
            id: input_coinpaprika_id
            visible: !is_erc20
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Coinpaprika ID"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the Coinpaprika ID"))
            field.text: "test-coin"
        }

        DefaultCheckBox {
            id: input_active
            visible: !is_erc20
            text: API.get().settings_pg.empty_string + (qsTr("Active"))
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Previous"))
                Layout.fillWidth: true
                onClicked: root.previousPage()
            },

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Preview"))
                Layout.fillWidth: true
                enabled: (!input_name.visible || input_name.field.text !== "") &&
                         (!input_contract_address.visible || input_contract_address.field.text !== "") &&
                         (!input_coinpaprika_id.visible || input_coinpaprika_id.field.text !== "")
                onClicked: {
                    prepareConfigs()
                    root.nextPage()
                }
            }
        ]
    }

    // Preview
    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Preview"))

        DefaultImage {
            Layout.alignment: Qt.AlignHCenter

            Layout.preferredWidth: 64
            Layout.preferredHeight: Layout.preferredWidth
            source: input_logo.path
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        TextAreaWithTitle {
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Config Fields"))
            field.readOnly: true
            remove_newline: false
            copyable: true
            field.text: General.prettifyJSON(config_fields)
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Previous"))
                Layout.fillWidth: true
                onClicked: root.previousPage()
            },

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Submit"))
                Layout.fillWidth: true
                onClicked: root.nextPage()
            }
        ]
    }
}
