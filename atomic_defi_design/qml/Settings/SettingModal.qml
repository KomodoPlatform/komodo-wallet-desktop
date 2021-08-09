//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import QtQml 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Universal 2.12

//! 3rdParty Imports
import Qaterial 1.0 as Qaterial

//! Project Imports
import "../Components"
import "../Constants" as Constants
import App 1.0


Qaterial.Dialog
{
    property alias selectedMenuIndex: menu_list.currentIndex

    function disconnect() {
        let dialog = app.showText({
            "title": qsTr("Confirm Logout"),
            text: qsTr("Are you sure you want to log out?") ,
            standardButtons: Dialog.Yes | Dialog.Cancel,
            warning: true,
            width: 300,
            iconSource: Qaterial.Icons.logout,
            iconColor: DexTheme.accentColor,
            yesButtonText: qsTr("Yes"),
            cancelButtonText: qsTr("Cancel"),
            onAccepted: function(text) {
                app.currentWalletName = ""
                API.app.disconnect()
                onDisconnect()
                dialog.close()
                dialog.destroy()
            }
        })
        
    }

    readonly property string mm2_version: API.app.settings_pg.get_mm2_version()
    property var recommended_fiats: API.app.settings_pg.get_recommended_fiats()
    property var fiats: API.app.settings_pg.get_available_fiats()
    property var enableable_coins_count: enableable_coins_count_combo_box.currentValue


    id: setting_modal
    width: 850
    height: 650
    anchors.centerIn: parent
    dim: true
    modal: true
    title: "Settings"
    header: Item{}
    Overlay.modal: Item {
        Rectangle {
            anchors.fill: parent
            color: DexTheme.surfaceColor
            opacity: .7
        }
    }
    background: FloatingBackground {
        color: DexTheme.dexBoxBackgroundColor
        radius: 3
    }
    padding: 0
    topPadding: 0
    bottomPadding: 0
    Item {
        width: parent.width
        height: 60
        Qaterial.AppBarButton {
            anchors.right: parent.right
            anchors.rightMargin: 10
            foregroundColor: DexTheme.foregroundColor
            icon.source: Qaterial.Icons.close
            anchors.verticalCenter: parent.verticalCenter
            onClicked: setting_modal.close()
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 20
            DexLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: "Settings"
                font: DexTypo.head6
            }
            DexLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: " - "+qsTr(menu_list.model[menu_list.currentIndex])
                opacity: .5
                font: DexTypo.head6
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            color: DexTheme.foregroundColor
            opacity: .10
            width: parent.width
            height: 1.5
        }

        Qaterial.DebugRectangle {
            anchors.fill: parent
            visible: false
        }
    }
    Item {
        width: parent.width
        height: parent.height-110
        y:60
        RowLayout {
            anchors.fill: parent
            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 240
                ListView {
                    id: menu_list
                    anchors.fill: parent
                    anchors.topMargin: 10
                    spacing: 10
                    currentIndex: 0
                    model: [qsTr("General"),qsTr("Language"),qsTr("User Interface"),qsTr("Security"),qsTr("About"),qsTr("Version")]
                    highlight: Item {
                        width: menu_list.width-20
                        x: 10
                        height: 45
                        DexRectangle {
                            anchors.fill: parent
                            height: 45
                            radius: 8
                            color: 'transparent'
                            border.width: 2
                            border.color: DexTheme.hoverColor
                        }
                    }

                    delegate: DexSelectableButton {
                        selected: false
                        text: modelData
                        outlined: false
                        onClicked: menu_list.currentIndex = index
                    }
                }
            }
            Rectangle {
                Layout.fillHeight: true
                width: 2
                color: DexTheme.foregroundColor
                opacity: .10
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                StackLayout {
                    anchors.fill: parent
                    currentIndex: menu_list.currentIndex
                    Item {
                        anchors.margins: 10
                        Column {
                            anchors.fill: parent
                            topPadding: 10
                            spacing: 15
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 30
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Enable Desktop Notifications")
                                }
                                DefaultSwitch {
                                    Layout.alignment: Qt.AlignVCenter
                                    Component.onCompleted: checked = API.app.settings_pg.notification_enabled
                                    onCheckedChanged: API.app.settings_pg.notification_enabled = checked
                                }
                            }
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 50
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Maximum number of enabled coins")
                                }
                                DexComboBox {
                                    id: enableable_coins_count_combo_box
                                    model: [10, 20, 50, 75, 100, 150, 200]
                                    currentIndex: model.indexOf(parseInt(atomic_settings2.value("MaximumNbCoinsEnabled")))
                                    onCurrentIndexChanged: atomic_settings2.setValue("MaximumNbCoinsEnabled", model[currentIndex])
                                }
                            }

                            SettingsButton {
                                width: parent.width-30
                                height: 50
                                title: qsTr("Logs")
                                buttonText: qsTr("Open Folder")
                                onClicked: openLogsFolder()
                            }

                            SettingsButton {
                                width: parent.width-30
                                height: 50
                                title: qsTr("Reset assets configuration")
                                buttonText: qsTr("Reset")
                                onClicked: {
                                    dialog = app.showText({
                                            title: qsTr("Reset assets configuration"),
                                            text: qsTr("This will reset your wallet config to default"),
                                            standardButtons: Dialog.Yes | Dialog.Cancel,
                                            yesButtonText: qsTr("Yes"),
                                            cancelButtonText: qsTr("Cancel"),
                                            onAccepted: function() {
                                                restart_modal.open()
                                                restart_modal.item.onTimerEnded = () => { API.app.settings_pg.reset_coin_cfg() }
                                            }
                                        })
                                    dialog.close()
                                }
                            }
                        }
                    }
                    Item {
                        Column {
                            anchors.fill: parent
                            topPadding: 10
                            spacing: 15
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 30
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Language") + ":"
                                }
                                Languages {
                                    Layout.alignment: Qt.AlignVCenter
                                }

                            }
                            Combo_fiat {
                                id: combo_fiat
                            }
                        }
                    }


                    Item {
                        Column {
                            anchors.fill: parent
                            topPadding: 10
                            spacing: 15
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 30
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Current Font")
                                }
                                DexComboBox {
                                    id: dexFont
                                    editable: true
                                    Layout.alignment: Qt.AlignVCenter
                                    model: ["Ubuntu", "Montserrat", "Roboto"]
                                    Component.onCompleted: {
                                        let current = DexTypo.fontFamily
                                        currentIndex = dexFont.model.indexOf(current)
                                    }
                                }
                            }
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 30

                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Theme")
                                }

                                DexComboBox {
                                    id: dexTheme
                                    Layout.alignment: Qt.AlignVCenter
                                    displayText: currentText.replace(".json","")
                                    model: API.qt_utilities.get_themes_list()
                                    Component.onCompleted: {
                                        let current = atomic_settings2.value("CurrentTheme")
                                        currentIndex = model.indexOf(current)
                                    }
                                }
                            }

                            SettingsButton {
                                width: parent.width-30
                                height: 50
                                buttonText: qsTr("Apply Changes")
                                onClicked: {
                                    atomic_settings2.setValue("CurrentTheme", dexTheme.currentText)
                                    atomic_settings2.sync()
                                    app.load_theme(dexTheme.currentText.replace(".json",""))
                                    DexTypo.fontFamily = dexFont.currentText
                                    
                                }
                            }
                        }
                    }
                    Item {
                        Column {
                            anchors.fill: parent
                            topPadding: 10
                            spacing: 15

                            ModalLoader {
                                id: view_seed_modal
                                sourceComponent: RecoverSeedModal {}
                            }

                            ModalLoader {
                                id: eula_modal
                                sourceComponent: EulaModal {
                                    close_only: true
                                }
                            }

                            ModalLoader {
                                id: camouflage_password_modal
                                sourceComponent: CamouflagePasswordModal {}
                            }

                            // Enabled 2FA option. (Disabled on Linux since the feature is not available on this platform yet)
                            RowLayout {
                                enabled: Qt.platform.os !== "linux" // Disable for Linux.
                                Component.onCompleted: console.log(Qt.platform.os)
                                visible: enabled
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: qsTr("Ask system's password before sending coins ? (2FA)")
                                }
                                DexSwitch {
                                    checked: parseInt(atomic_settings2.value("2FA")) === 1
                                    onCheckedChanged: {
                                        if (checked)
                                            atomic_settings2.setValue("2FA", 1)
                                        else
                                            atomic_settings2.setValue("2FA", 0)
                                        atomic_settings2.sync()
                                    }
                                }
                            }

                            SettingsButton {
                                width: parent.width-30
                                height: 50
                                title: qsTr("View seed and private keys")
                                buttonText: qsTr("Show")
                                onClicked: view_seed_modal.open()
                            }

                            SettingsButton {
                                width: parent.width-30
                                height: 50
                                title: qsTr("Setup Camouflage Password")
                                buttonText: qsTr("Open")
                                onClicked: camouflage_password_modal.open()
                            }

                        }
                    }

                    Item {
                        
                        Column {
                            
                            ModalLoader {
                                id: delete_wallet_modal
                                sourceComponent: DeleteWalletModal {}
                            }
                            
                            anchors.fill: parent
                            topPadding: 10
                            spacing: 15

                            SettingsButton {
                                width: parent.width-30
                                height: 50
                                title: qsTr("Disclaimer and ToS")
                                buttonText: qsTr("Show")
                                onClicked: eula_modal.open()
                            }

                        }
                    }
                    Item {
                        Column {
                            anchors.fill: parent
                            topPadding: 10
                            spacing: 15
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Application version")
                                }
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: API.app.settings_pg.get_version()
                                }
                            }
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("MM2 version")
                                }
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: API.app.settings_pg.get_mm2_version()
                                }
                            }
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Qt version")
                                }
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: qtversion
                                }
                            }
                        }
                    }
                }
            }
        }

        Qaterial.DebugRectangle {
            anchors.fill: parent
            visible: false
        }
    }
    Item {
        width: parent.width
        height: 50
        anchors.bottom: parent.bottom

        Row {
            spacing: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            DexAppButton {
                text: qsTr("Search Update")
                height: 40
                iconSource: Qaterial.Icons.update
                onClicked: new_update_modal.open()
            }
            
            DexAppButton {
                text: qsTr("Logout")
                height: 40
                iconSource: Qaterial.Icons.logout
                onClicked: {
                    disconnect()
                    setting_modal.close()
                }
            }
        }

        Rectangle {
            anchors.top: parent.top
            color: DexTheme.foregroundColor
            opacity: .10
            width: parent.width
            height: 1.5
        }

    }
}
