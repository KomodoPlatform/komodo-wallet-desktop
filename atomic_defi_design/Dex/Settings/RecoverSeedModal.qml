import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

MultipageModal
{
    id: root

    property var portfolio_model: API.app.portfolio_pg.portfolio_mdl
    property var settings_page: API.app.settings_pg

    property bool wrongPassword: false

    function tryViewKeysAndSeed()
    {
        if (!submitButton.enabled) return

        const result = API.app.settings_pg.retrieve_seed(API.app.wallet_mgr.wallet_default_name, inputPassword.field.text)

        if (result.length === 2)
        {
            seedLabel.text = result[0]
            rpcPwLabel.text = result[1]
            wrongPassword = false
            root.nextPage()
            loading.running = true
        }
        else
        {
            wrongPassword = true
        }
    }

    width: 820

    onClosed:
    {
        wrongPassword = false
        inputPassword.reset()
        seedLabel.text = ""
        rpcPwLabel.text = ""
        portfolio_model.clean_priv_keys()
        currentIndex = 0
    }

    MultipageModalContent
    {
        titleText: qsTr("View seed and private keys")

        DefaultText
        {
            text_value: qsTr("Please enter your password to view the seed.")
        }

        DexAppPasswordField
        {
            id: inputPassword
            Layout.fillWidth: true
            forceFocus: true
            field.onAccepted: tryViewKeysAndSeed()
            background.color: Dex.CurrentTheme.floatingBackgroundColor
            leftIconColor: Dex.CurrentTheme.foregroundColor
            hideFieldButton.icon.color: Dex.CurrentTheme.foregroundColor
        }

        // Footer
        RowLayout
        {
            Layout.preferredWidth: parent.width
            Layout.topMargin: 30
            DefaultButton
            {
                text: qsTr("Cancel")
                Layout.preferredWidth: parent.width / 100 * 48
                onClicked: root.close()
            }

            PrimaryButton
            {
                id: submitButton
                Layout.preferredWidth: parent.width / 100 * 48
                enabled: inputPassword.field.length > 0
                text: qsTr("View")
                onClicked: tryViewKeysAndSeed()
            }
        }
    }

    MultipageModalContent
    {
        titleText: qsTr("View seed and private keys")

        Timer
        {
            id: loading
            repeat: true
            running: false
            onTriggered:
            {
                if (!settings_page.fetching_priv_keys_busy)
                {
                    repeat = false
                    busyView.visible = false
                    busyView.enabled = false
                    seedContainer.visible = true
                    seedContainer.enabled = true
                    coinsList.visible = true
                    coinsList.enabled = true
                }
            }
        }

        DefaultBusyIndicator { id: busyView; Layout.alignment: Qt.AlignHCenter }

        RowLayout
        {
            id: seedContainer
            visible: false
            enabled: false
            spacing: 10

            // Logo
            ColumnLayout
            {
                DefaultImage
                {
                    source: Dex.CurrentTheme.bigLogoPath
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 144
                    Layout.preferredHeight: 144
                }
            }

            ColumnLayout
            {
                spacing: 10

                // Seed
                RowLayout
                {
                    spacing: 5

                    Qaterial.RawMaterialButton
                    {
                        backgroundImplicitWidth: 40
                        backgroundImplicitHeight: 30
                        backgroundColor: "transparent"
                        icon.source: Qaterial.Icons.qrcodeScan
                        icon.color: Dex.CurrentTheme.foregroundColor
                        onClicked:
                        {
                            qrcodeModal.qrcodeSvg = API.qt_utilities.get_qrcode_svg_from_string(seedLabel.text)
                            qrcodeModal.open()
                        }
                    }

                    Qaterial.RawMaterialButton
                    {
                        backgroundImplicitWidth: 40
                        backgroundImplicitHeight: 30
                        backgroundColor: "transparent"
                        icon.source: Qaterial.Icons.contentCopy
                        icon.color: Dex.CurrentTheme.foregroundColor
                        onClicked:
                        {
                            API.qt_utilities.copy_text_to_clipboard(seedLabel.text)
                            app.notifyCopy(qsTr("Seed"), qsTr("copied to clipboard"))
                        }
                    }

                    ColumnLayout
                    {
                        DefaultText { text: qsTr("Backup Seed"); font.pixelSize: Style.textSizeSmall2 }
                        DefaultText { id: seedLabel; Layout.fillWidth: true; font.pixelSize: Style.textSizeSmall1; maximumLineCount: 4; wrapMode: Text.Wrap }
                    }
                }

                // RPC Password
                RowLayout
                {
                    spacing: 5

                    Qaterial.RawMaterialButton
                    {
                        backgroundImplicitWidth: 40
                        backgroundImplicitHeight: 30
                        backgroundColor: "transparent"
                        icon.source: Qaterial.Icons.qrcodeScan
                        icon.color: Dex.CurrentTheme.foregroundColor
                        onClicked:
                        {
                            qrcodeModal.qrcodeSvg = API.qt_utilities.get_qrcode_svg_from_string(rpcPwLabel.text)
                            qrcodeModal.open()
                        }
                    }

                    Qaterial.RawMaterialButton
                    {
                        backgroundImplicitWidth: 40
                        backgroundImplicitHeight: 30
                        backgroundColor: "transparent"
                        icon.source: Qaterial.Icons.contentCopy
                        icon.color: Dex.CurrentTheme.foregroundColor
                        onClicked:
                        {
                            API.qt_utilities.copy_text_to_clipboard(rpcPwLabel.text)
                            app.notifyCopy(qsTr("RPC Password"), qsTr("copied to clipboard"))
                        }
                    }

                    ColumnLayout
                    {
                        DefaultText { text: qsTr("RPC Password"); font.pixelSize: Style.textSizeSmall2 }
                        DefaultText { id: rpcPwLabel; Layout.fillWidth: true; font.pixelSize: Style.textSizeSmall1; maximumLineCount: 4; wrapMode: Text.WrapAnywhere }
                    }
                }
            }
        }

        HorizontalLine { Layout.topMargin: 10; Layout.fillWidth: true }

        DefaultTextField
        {
            visible: coinsList.visible
            enabled: coinsList.enabled
            Layout.topMargin: 10
            Layout.preferredWidth: parent.width / 3
            placeholderText: qsTr("Search a coin.")
            onTextChanged: portfolio_model.portfolio_proxy_mdl.setFilterFixedString(text)
            Component.onDestruction: portfolio_model.portfolio_proxy_mdl.setFilterFixedString("")
        }

        DefaultRectangle
        {
            id: coinsList
            visible: false
            enabled: false
            Layout.topMargin: 10
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 300
            Layout.alignment: Qt.AlignHCenter
            radius: 10
            border.color: Dex.CurrentTheme.lineSeparatorColor
            border.width: 2

            DefaultListView
            {
                anchors.fill: parent
                model: portfolio_mdl.portfolio_proxy_mdl

                delegate: ColumnLayout
                {
                    width: coinsList.width

                    RowLayout
                    {
                        Layout.fillWidth: true
                        Layout.leftMargin: 5

                        ColumnLayout
                        {
                            Layout.fillWidth: true

                            DefaultImage
                            {
                                source: General.coinIcon(model.ticker)
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                            }

                            DefaultText
                            {
                                text: model.name
                                font.pixelSize: Style.textSizeSmall5
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 100
                            }
                        }

                        ColumnLayout
                        {
                            // Public Address
                            RowLayout
                            {
                                Qaterial.RawMaterialButton
                                {
                                    backgroundImplicitWidth: 40
                                    backgroundImplicitHeight: 30
                                    backgroundColor: "transparent"
                                    icon.source: Qaterial.Icons.qrcodeScan
                                    icon.color: Dex.CurrentTheme.foregroundColor
                                    onClicked:
                                    {
                                        qrcodeModal.qrcodeSvg = API.qt_utilities.get_qrcode_svg_from_string(publicAddress.text)
                                        qrcodeModal.open()
                                    }
                                }

                                Qaterial.RawMaterialButton
                                {
                                    backgroundImplicitWidth: 40
                                    backgroundImplicitHeight: 30
                                    backgroundColor: "transparent"
                                    icon.source: Qaterial.Icons.contentCopy
                                    icon.color: Dex.CurrentTheme.foregroundColor
                                    onClicked:
                                    {
                                        API.qt_utilities.copy_text_to_clipboard(publicAddress.text)
                                        app.notifyCopy(model.name, qsTr("Public Address copied to clipboard"))
                                    }
                                }

                                ColumnLayout
                                {
                                    Layout.fillWidth: true

                                    DefaultText
                                    {
                                        text: qsTr("Public Address")
                                        font.pixelSize: Style.textSizeSmall2
                                    }

                                    DefaultText
                                    {
                                        id: publicAddress
                                        text: model.public_address
                                        font.pixelSize: Style.textSizeSmall1
                                        maximumLineCount: 4; wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }

                            // Private Key
                            RowLayout
                            {
                                Qaterial.RawMaterialButton
                                {
                                    backgroundImplicitWidth: 40
                                    backgroundImplicitHeight: 30
                                    backgroundColor: "transparent"
                                    icon.source: Qaterial.Icons.qrcodeScan
                                    icon.color: Dex.CurrentTheme.foregroundColor
                                    onClicked:
                                    {
                                        qrcodeModal.qrcodeSvg = API.qt_utilities.get_qrcode_svg_from_string(privateKey.text)
                                        qrcodeModal.open()
                                    }
                                }

                                Qaterial.RawMaterialButton
                                {
                                    backgroundImplicitWidth: 40
                                    backgroundImplicitHeight: 30
                                    backgroundColor: "transparent"
                                    icon.source: Qaterial.Icons.contentCopy
                                    icon.color: Dex.CurrentTheme.foregroundColor
                                    onClicked:
                                    {
                                        API.qt_utilities.copy_text_to_clipboard(privateKey.text)
                                        app.notifyCopy(model.name, qsTr("Private Key copied to clipboard"))
                                    }
                                }

                                ColumnLayout
                                {
                                    Layout.fillWidth: true

                                    DefaultText
                                    {
                                        text: qsTr("Private Key")
                                        font.pixelSize: Style.textSizeSmall2
                                    }

                                    DefaultText
                                    {
                                        id: privateKey
                                        text: model.priv_key
                                        font.pixelSize: Style.textSizeSmall1
                                        maximumLineCount: 4; wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }
                        }
                    }
                    HorizontalLine { Layout.fillWidth: true }
                }
            }
        }

        ModalLoader
        {
            id: qrcodeModal

            property string qrcodeSvg

            sourceComponent: Popup
            {
                id: popup

                x: (root.width - width) / 2
                y: ((root.height - height) / 2) - 250

                onClosed: qrcodeSvg = ""

                background: Image
                {
                    source: qrcodeSvg
                    sourceSize.width: 200
                    sourceSize.height: 200
                }
            }
        }
    }
}
