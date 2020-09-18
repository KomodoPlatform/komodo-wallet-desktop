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
        currentIndex = 0
        reset()
    }

    property var config_fields: ({})


    function prepareConfigs() {
        var fields = {}

        const addToConfig = (input_component, key, value) => {
            if(input_component.enabled) fields[key] = value
        }

        addToConfig(input_type,             "type",             input_type.currentText)
        addToConfig(input_ticker,           "ticker",           input_ticker.field.text.toUpperCase())
        addToConfig(input_logo,             "image_path",       input_logo.path.replace("file://", ""))
        addToConfig(input_name,             "name",             input_name.field.text)
        addToConfig(input_contract_address, "contract_address", input_contract_address.field.text)
        addToConfig(input_active,           "active",           input_active.checked)
        addToConfig(input_coinpaprika_id,   "coinpaprika_id",   input_coinpaprika_id.field.text)

        root.config_fields = fields
    }

    function submitConfig() {
        const fields = General.clone(config_fields)
        if(fields.type === "ERC-20") {
            console.log("adding new coin:", JSON.stringify(fields))
            API.get().settings_pg.process_erc_20_token_add(fields.contract_address, fields.coinpaprika_id, fields.image_path)
        }
    }

    function reset() {
        //input_type.currentIndex = 0 // Keep same type, user might wanna add multiple of same type
        input_ticker.field.text = ""
        input_logo.path = ""
        input_name.field.text = ""
        input_contract_address.field.text = ""
        input_active.checked = false
        input_coinpaprika_id.field.text = "test-coin"
    }

    readonly property bool is_erc20: input_type.currentText === "ERC-20"
    readonly property bool is_qrc20: input_type.currentText === "QRC-20"
    readonly property bool has_contract_address: is_erc20 || is_qrc20

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
                onClicked: {
                    root.reset()
                    root.nextPage()
                }
            }
        ]
    }

    // Ticker page
    ModalContent {
        title: API.get().settings_pg.empty_string + (has_contract_address ? qsTr("Enter the contract address") : qsTr("Choose the coin ticker"))

        TextFieldWithTitle {
            id: input_ticker
            enabled: !has_contract_address
            visible: enabled
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Ticker"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the ticker"))
        }

        AddressFieldWithTitle {
            id: input_contract_address
            enabled: has_contract_address
            visible: enabled
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Contract Address"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the contract address"))
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
                enabled: (!input_ticker.enabled || input_ticker.field.text !== "") &&
                         (!input_contract_address.enabled || input_contract_address.field.text !== "")
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

            property string path
            onFileUrlChanged: path = input_logo.fileUrl.toString()

            readonly property bool enabled: true // Config preparation function searches for this

            title: API.get().settings_pg.empty_string + (qsTr("Please choose the coin logo"))
            folder: shortcuts.pictures
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

        DefaultText {
            visible: has_contract_address
            Layout.fillWidth: true
            text_value: API.get().settings_pg.empty_string + (qsTr("All configuration fields will be fetched using the contract address you provided."))
        }

        TextFieldWithTitle {
            id: input_name
            enabled: !has_contract_address
            visible: enabled
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Name"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the name"))
        }

        TextFieldWithTitle {
            id: input_coinpaprika_id
            enabled: !has_contract_address
            visible: enabled
            Layout.fillWidth: true
            title: API.get().settings_pg.empty_string + (qsTr("Coinpaprika ID"))
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the Coinpaprika ID"))
        }

        DefaultCheckBox {
            id: input_active
            enabled: !has_contract_address
            visible: enabled
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
                enabled: (!input_name.enabled || input_name.field.text !== "") &&
                         (!input_coinpaprika_id.enabled || input_coinpaprika_id.field.text !== "")
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
                onClicked: {
                    root.submitConfig()
                    root.nextPage()
                }
            }
        ]
    }
}
