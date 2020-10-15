import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Item {
    id: root
    function disconnect() {
        API.app.disconnect()
        onDisconnect()
    }

    function reset() {

    }

    function onOpened() {
        if(mm2_version === '') mm2_version = API.app.get_mm2_version()
    }

    property string mm2_version: ''
    property var fiats: API.app.settings_pg.get_available_fiats()

    InnerBackground {
        id: layout_background
        anchors.centerIn: parent
        Layout.alignment: Qt.AlignHCenter

        width: 650
        height: 750

        content: ColumnLayout {
            width: layout_background.width
            height: layout_background.height

            ComboBoxWithTitle {
                id: combo_fiat
                title: qsTr("Fiat")
                Layout.fillWidth: true
                Layout.leftMargin: 30
                Layout.rightMargin: Layout.leftMargin

                model: fiats

                property bool initialized: false
                onCurrentIndexChanged: {
                    if(initialized) {
                        const new_fiat = fiats[currentIndex]
                        API.app.settings_pg.current_fiat = new_fiat
                        API.app.settings_pg.current_currency = new_fiat
                    }
                }
                Component.onCompleted: {
                    currentIndex = model.indexOf(API.app.settings_pg.current_fiat)
                    initialized = true
                }
            }

            Languages {
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
            }

            HorizontalLine {
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                Layout.topMargin: 10
            }

            DefaultSwitch {
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                text: qsTr("Enable Desktop Notifications")
                Component.onCompleted: checked = API.app.settings_pg.notification_enabled
                onCheckedChanged: API.app.settings_pg.notification_enabled = checked
            }

            DefaultButton {
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                text: qsTr("Open Logs Folder")
                onClicked: openLogsFolder()
            }

            DefaultButton {
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                text: qsTr("View Seed")
                onClicked: recover_seed_modal.open()
            }

            RecoverSeedModal {
                id: recover_seed_modal
            }

            HorizontalLine {
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
            }

            DefaultButton {
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                text: qsTr("Disclaimer and ToS")
                onClicked: eula.open()
            }

            EulaModal {
                id: eula
                close_only: true
            }

            HorizontalLine {
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
            }

            DefaultButton {
                visible: !API.app.is_pin_cfg_enabled()
                text: qsTr("Setup Camouflage Password")
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                onClicked: camouflage_password_modal.open()
            }

            CamouflagePasswordModal {
                id: camouflage_password_modal
            }

            DangerButton {
                text: qsTr("Delete Wallet")
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                onClicked: delete_wallet_modal.open()
            }

            DeleteWalletModal {
                id: delete_wallet_modal
            }

            DefaultButton {
                Layout.fillWidth: true
                Layout.leftMargin: combo_fiat.Layout.leftMargin
                Layout.rightMargin: Layout.leftMargin
                text: qsTr("Log out")
                onClicked: disconnect()
            }
        }
    }

    DefaultText {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: anchors.bottomMargin
        text_value: qsTr("mm2 version") + ":  " + mm2_version
        font.pixelSize: Style.textSizeSmall
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
