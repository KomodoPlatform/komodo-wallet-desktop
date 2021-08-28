import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import App 1.0

BasicModal {
    id: root

    property var portfolio_model: API.app.portfolio_pg.portfolio_mdl
    property var settings_page: API.app.settings_pg

    property bool wrong_password: false

    function tryViewSeed() {
        if(!submit_button.enabled) return

        const result = API.app.settings_pg.retrieve_seed(API.app.wallet_mgr.wallet_default_name, input_password.field.text)

        if(result.length === 2) {
            seed_text.text = result[0]
            rpc_pw.text = result[1]
            wrong_password = false
            root.nextPage()
            loading.running = true
        }
        else {
            wrong_password = true
        }
    }

    width: 800

    onClosed: {
        wrong_password = false
        input_password.reset()
        seed_text.text = ""
        portfolio_model.clean_priv_keys()
        currentIndex = 0
    }

    ModalContent { // Password checking
        title: qsTr("View seed and private keys")

        ColumnLayout {
            DefaultText {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignHCenter

                text_value: qsTr("Please enter your password to view the seed.")
            }

            PasswordForm {
                id: input_password
                Layout.fillWidth: true
                confirm: false
                field.onAccepted: tryViewSeed()
            }

            DefaultText {
                text_value: qsTr("Wrong Password")
                color: Style.colorRed
                visible: wrong_password
            }
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: root.close()
            },

            PrimaryButton {
                id: submit_button
                text: qsTr("View")
                Layout.fillWidth: true
                enabled: input_password.isValid()
                onClicked: tryViewSeed()
            }
        ]
    }

    ModalContent {
        title: qsTr("View seed and private keys")
        Layout.fillWidth: true

        Timer {
            id: loading

            repeat: true
            running: false
            onTriggered: {
                if (!settings_page.fetching_priv_keys_busy) {
                    repeat = false
                    busy_view.visible = false
                    busy_view.enabled = false
                    seed_container.visible = true
                    seed_container.enabled = true
                    coins_list.visible = true
                    coins_list.enabled = true
                }
            }
        }

        DefaultBusyIndicator {
            id: busy_view

            Layout.alignment: Qt.AlignHCenter
        }

        DefaultRectangle {
            id: seed_container
            visible: false
            enabled: false
            height: 120
            width: parent.width

            RowLayout {
                Layout.fillWidth: true
                anchors.verticalCenter: parent.verticalCenter

                DefaultImage {
                    Layout.leftMargin: 10
                    source: General.image_path + "dex-logo-sidebar.png"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                DefaultText {
                    Layout.leftMargin: 5
                    Layout.preferredWidth: 100
                    text: API.app_name
                    font.pixelSize: Style.textSizeSmall5
                }

                ColumnLayout {
                    RowLayout {
                Qaterial.RawMaterialButton {
                    implicitWidth: 45
                    backgroundColor: "transparent"
                    icon.source: Qaterial.Icons.qrcodeScan

                    onClicked: {
                        qrcode_modal.qrcode_svg = API.qt_utilities.get_qrcode_svg_from_string(seed_text.text)
                        qrcode_modal.open()
                    }
                }

                Qaterial.RawMaterialButton { //! Copy clipboard button
                    implicitWidth: 45
                    backgroundColor: "transparent"
                    icon.source: Qaterial.Icons.contentCopy

                    onClicked: API.qt_utilities.copy_text_to_clipboard(seed_text.text)
                }
                    }
                    RowLayout {
                        Qaterial.RawMaterialButton {
                            implicitWidth: 45
                            backgroundColor: "transparent"
                            icon.source: Qaterial.Icons.qrcodeScan

                            onClicked: {
                                qrcode_modal.qrcode_svg = API.qt_utilities.get_qrcode_svg_from_string(rpc_pw.text)
                                qrcode_modal.open()
                            }
                        }

                        Qaterial.RawMaterialButton { //! Copy clipboard button
                            implicitWidth: 45
                            backgroundColor: "transparent"
                            icon.source: Qaterial.Icons.contentCopy

                            onClicked: API.qt_utilities.copy_text_to_clipboard(rpc_pw.text)
                        }
                    }
                }

                ColumnLayout {
                    // Seed
                    DefaultText {
                        text: qsTr("Backup seed")
                        color: Style.modalValueColor
                        font.pixelSize: Style.textSizeSmall2
                    }
                    DefaultText {
                        Layout.preferredWidth: 400
                        id: seed_text
                        font.pixelSize: Style.textSizeSmall1
                    }

                    // RPC Password
                    DefaultText {
                        Layout.topMargin: 10
                        text: qsTr("RPC Password")
                        color: Style.modalValueColor
                        font.pixelSize: Style.textSizeSmall2
                    }

                    DefaultText {
                        id: rpc_pw
                        font.pixelSize: Style.textSizeSmall3
                    }
                }
            }
        }

        // Search input
        DefaultTextField {
            Layout.fillWidth: true
            placeholderText: qsTr("Search a coin.")
            onTextChanged: portfolio_model.portfolio_proxy_mdl.setFilterFixedString(text)

            Component.onDestruction: portfolio_model.portfolio_proxy_mdl.setFilterFixedString("")
        }

        DexListView {
            id: coins_list

            visible: false
            enabled: false

            Layout.fillWidth: true
            Layout.fillHeight: true
            model: portfolio_mdl.portfolio_proxy_mdl
            
            delegate: DefaultRectangle {
                height: seed_container.height
                width: seed_container.width

                RowLayout {
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter

                    DefaultImage {
                        Layout.leftMargin: 10
                        source: General.coinIcon(model.ticker)
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                    }

                    DefaultText {
                        Layout.preferredWidth: 100
                        Layout.leftMargin: 5
                        text: model.name
                        font.pixelSize: Style.textSizeSmall5
                    }

                    ColumnLayout { // QR/Copy buttons
                        spacing: 3

                        RowLayout {
                            Qaterial.RawMaterialButton {
                                Layout.topMargin: 2
                                implicitWidth: 45
                                backgroundColor: "transparent"
                                icon.source: Qaterial.Icons.qrcodeScan

                                onClicked: {
                                    qrcode_modal.qrcode_svg = API.qt_utilities.get_qrcode_svg_from_string(model.public_address)
                                    qrcode_modal.open()
                                }
                            }

                            Qaterial.RawMaterialButton { //! Copy clipboard button
                                implicitWidth: 45
                                backgroundColor: "transparent"
                                icon.source: Qaterial.Icons.contentCopy

                                onClicked: API.qt_utilities.copy_text_to_clipboard(model.public_address)
                            }
                        }

                        RowLayout {
                            Qaterial.RawMaterialButton {
                                implicitWidth: 45
                                backgroundColor: "transparent"
                                icon.source: Qaterial.Icons.qrcodeScan

                                onClicked: {
                                    qrcode_modal.qrcode_svg = API.qt_utilities.get_qrcode_svg_from_string(model.priv_key)
                                    qrcode_modal.open()
                                }
                            }

                            Qaterial.RawMaterialButton { //! Copy clipboard button
                                implicitWidth: 45
                                backgroundColor: "transparent"
                                icon.source: Qaterial.Icons.contentCopy

                                onClicked: API.qt_utilities.copy_text_to_clipboard(model.priv_key)
                            }
                        }
                    }

                    ColumnLayout { // Addresses
                        DefaultText {
                            text: qsTr("Public Address")
                            color: Style.modalValueColor
                            font.pixelSize: Style.textSizeSmall2
                        }

                        DefaultText {
                            text: model.public_address
                            font.pixelSize: Style.textSizeSmall3
                        }

                        DefaultText {
                            Layout.topMargin: 10
                            text: qsTr("Private Key")
                            color: Style.modalValueColor
                            font.pixelSize: Style.textSizeSmall2
                        }

                        DefaultText {
                            text: model.priv_key
                            font.pixelSize: Style.textSizeSmall3
                        }
                    }
                }
            }
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
        ]

        ModalLoader {
            id: qrcode_modal

            property string qrcode_svg

            sourceComponent: Popup {
                id: popup

                x: (root.width - width) / 2
                y: ((root.height - height) / 2) - 250

                onClosed: qrcode_svg = ""

                background: Image {
                    source: qrcode_svg

                    sourceSize.width: 200
                    sourceSize.height: 200
                }
            }
        }
    }
}
