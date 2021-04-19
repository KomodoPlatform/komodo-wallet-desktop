import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0


import QtQuick.Window 2.12

import Qaterial 1.0 as Qaterial

// Project Imports
import "../Components"
import "../Constants"


Qaterial.Dialog {

    function disconnect() {
        API.app.disconnect()
        onDisconnect()
    }

    readonly property string mm2_version: API.app.settings_pg.get_mm2_version()
    property var recommended_fiats: API.app.settings_pg.get_recommended_fiats()
    property var fiats: API.app.settings_pg.get_available_fiats()



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
            color: theme.surfaceColor
            opacity: .7
        }
    }
    background: FloatingBackground {
        color: theme.dexBoxBackgroundColor
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
            foregroundColor: theme.foregroundColor
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
                font: theme.textType.head6
            }
            DexLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: " - "+qsTr(menu_list.model[menu_list.currentIndex])
                opacity: .5
                font: theme.textType.head6
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            color: theme.foregroundColor
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
                        Rectangle {
                            anchors.fill: parent
                            height: 45
                            radius: 5
                            color: theme.hightlightColor
                        }
                    }

                    delegate: DexSelectableButton {
                        selected: false
                        text: modelData
                        onClicked: menu_list.currentIndex = index
                    }
                }
            }
            Rectangle {
                Layout.fillHeight: true
                width: 2
                color: theme.foregroundColor
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
                                    //text: qsTr("Enable Desktop Notifications")
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
                                    text: qsTr("Logs")
                                }
                                DexButton {
                                    text: qsTr("Open Folder")
                                    implicitHeight: 37
                                     onClicked: {
                                        openLogsFolder()
                                    }
                                }
                            }
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Reset assets configuration")
                                }
                                DexButton {
                                    text: qsTr("Reset")
                                    implicitHeight: 37
                                    onClicked: {
                                        restart_modal.open()
                                        restart_modal.item.task_before_restart = () => { API.app.settings_pg.reset_coin_cfg() }
                                    }
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
                                    text: qsTr("Use QtTextRendering Or NativeTextRendering")
                                }
                                DefaultSwitch {
                                    property bool firstTime: true
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.leftMargin: combo_fiat.Layout.leftMargin
                                    Layout.rightMargin: Layout.leftMargin
                                    checked: parseInt(atomic_settings2.value("FontMode")) === 1
                                    //text: qsTr("Use QtTextRendering Or NativeTextRendering")
                                    onCheckedChanged: {
                                        if(checked){
                                            atomic_settings2.setValue("FontMode", 1)
                                        }else {
                                            atomic_settings2.setValue("FontMode", 0)
                                        }
                                        if(firstTime) {
                                            firstTime = false
                                        }else {
                                            restart_modal.open()
                                        }

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
                                    onCurrentTextChanged: {
//                                        atomic_settings2.setValue("CurrentTheme", currentText)
//                                        atomic_settings2.sync()
//                                        app.load_theme(currentText.replace(".json",""))
                                    }
                                }
                            }
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("")
                                }
                                DexButton {
                                    text: qsTr("Apply Theme")
                                    implicitHeight: 37
                                     onClicked: {
                                        atomic_settings2.setValue("CurrentTheme", dexTheme.currentText)
                                        atomic_settings2.sync()
                                        app.load_theme(dexTheme.currentText.replace(".json",""))
                                    }
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

                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("View seed and private keys")
                                }
                                DexButton {
                                    text: qsTr("Show")
                                    implicitHeight: 37
                                    onClicked: view_seed_modal.open()
                                }
                            }

                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Setup Camouflage Password")
                                }
                                DexButton {
                                    text: qsTr("Open")
                                    implicitHeight: 37
                                    onClicked: camouflage_password_modal.open()
                                }
                            }

                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    //text:
                                }
                                DexButton {
                                    text: qsTr("Delete Wallet")
                                    implicitHeight: 37
                                    onClicked: delete_wallet_modal.open()
                                }
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
                            RowLayout {
                                width: parent.width-30
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: 60
                                DexLabel {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: qsTr("Disclaimer and ToS")
                                }
                                DexButton {
                                    text: qsTr("Show")
                                    implicitHeight: 37
                                    onClicked: eula_modal.open()
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
        DexSelectableButton {
            enabled: false
            selected: true
            anchors.right: logout_button.left
            anchors.rightMargin: 10
            anchors.horizontalCenter: undefined
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            height: 40
            width: 175
            Row {
                anchors.centerIn: parent
                Qaterial.ColorIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qaterial.Icons.update
                }
                spacing: 10
                DexLabel {
                    text: qsTr("Search Update")
                    anchors.verticalCenter: parent.verticalCenter
                    font: theme.textType.button
                }
                opacity: .6
            }
            onClicked: new_update_modal.open()
        }

        DexSelectableButton {
            id: logout_button
            selected: true
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.horizontalCenter: undefined
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            height: 40
            width: 130
            Row {
                anchors.centerIn: parent
                Qaterial.ColorIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qaterial.Icons.logout
                }
                spacing: 10
                DexLabel {
                    text: qsTr("Logout")
                    anchors.verticalCenter: parent.verticalCenter
                    font: theme.textType.button
                }
                opacity: .6
            }
            onClicked: disconnect()

        }

        Rectangle {
            anchors.top: parent.top
            color: theme.foregroundColor
            opacity: .10
            width: parent.width
            height: 1.5
        }

    }

    Component.onCompleted: {
        //open()
    }
}
