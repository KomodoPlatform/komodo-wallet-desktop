import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

import Qaterial 1.0 as Qaterial

import QtQuick.Window 2.15

import "../Components"
import "../Constants"
import App 1.0
import "../Settings"

SetupPage {
    // Override
    id: _setup
    property
    var onClickedNewUser: () => {}
    property
    var onClickedRecoverSeed: () => {}
    property
    var onClickedWallet: () => {}


    // Local
    function updateWallets() {
        wallets = API.app.wallet_mgr.get_wallets()
    }

    function onClickedLogin(password) {
        if (API.app.wallet_mgr.login(password, selected_wallet_name)) {
            console.log("Success: Login")
            app.currentWalletName = selected_wallet_name
            return true
        } else {
            console.log("Failed: Login")
            return false
        }
    }
    property
    var wallets: ([])

    image_path: (bottomDrawer.y === 0 && bottomDrawer.visible) ? "" : "file:///" + atomic_logo_path + "/" + DexTheme.bigSidebarLogo
    image_margin: 30
    Drawer {
        id: bottomDrawer
        width: parent.width
        height: parent.height
        edge: Qt.BottomEdge
        dim: false //
        modal: false
        background: Item {
            DexRectangle {
                id: _drawerBG
                anchors.fill: parent
                radius: 0
                border.width: 0
                color: 'black'
                opacity: .8
            }
            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 250
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                Image {
                    /*width: 200 
                    height: 130*/
                    source: "file:///" + atomic_logo_path + "/" + DexTheme.bigSidebarLogo
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                DexLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "%1 wallet".arg(selected_wallet_name)
                    color: DexTheme.foregroundColorLightColor4
                    font: DexTypo.body1
                    topPadding: 10
                }
                Connections {
                    target: bottomDrawer
                    function onVisibleChanged() {
                        _inputPassword.field.text = ""
                    }
                }

                DexAppPasswordField {
                    id: _inputPassword
                    height: 50
                    width: 300
                    anchors.horizontalCenter: parent.horizontalCenter
                    field.onAccepted: {
                        if (_keyChecker.isValid()) {
                            if (onClickedLogin(field.text)) {
                                bottomDrawer.close()
                                app.current_page = idx_initial_loading
                            } else {
                                error = true
                            }
                        } else {
                            error = true
                        }
                    }
                }

                DexKeyChecker {
                    id: _passwordChecker
                    visible: false
                    field: _inputPassword.field
                }

                DexButton {
                    radius: width
                    width: 150
                    text: qsTr("connect")
                    opacity: enabled ? 1 : 0.6
                    enabled: _passwordChecker.isValid()
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        _inputPassword.field.accepted()
                    }
                }

                DexKeyChecker {
                    id: _keyChecker
                    field: _inputPassword.field
                    visible: false
                }
            }
            Qaterial.AppBarButton {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 60
                anchors.horizontalCenter: parent.horizontalCenter
                width: 80
                icon.width: 40
                icon.height: 40
                icon.source: Qaterial.Icons.close
                onClicked: bottomDrawer.close()
            }
        }

    }
    content: ColumnLayout {
        id: content_column
        width: 400
        spacing: Style.rowSpacing
        opacity: (bottomDrawer.y === 0 && bottomDrawer.visible) ? .3 : 1
        RowLayout {
            Layout.fillWidth: true
            DexLabel {
                font: DexTypo.head6
                text_value: qsTr("Welcome")
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
            DexLanguage {
                Layout.preferredWidth: 55
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DexAppButton {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignLeft
            Layout.minimumWidth: 350
            leftPadding: 20
            text: qsTr("New Wallet")
            Layout.preferredHeight: 50
            radius: 8
            //backgroundColor: DexTheme.accentColor
            onClicked: onClickedNewUser()
        }

        DexAppButton {
            text: qsTr("Import wallet")
            horizontalAlignment: Qt.AlignLeft
            //backgroundColor: DexTheme.accentColor
            leftPadding: 20
            radius: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            onClicked: onClickedRecoverSeed()
        }

        // Wallets
        ColumnLayout {
            spacing: Style.rowSpacing

            visible: wallets.length > 0

            DexLabel {
                text_value: qsTr("My Wallets")
                font.pixelSize: Style.textSizeSmall2
                Layout.alignment: Qt.AlignHCenter
            }
            Item {
                height: 15
                Layout.fillWidth: true
                Rectangle {
                    height: 2
                    width: parent.width
                    color: DexTheme.accentColor
                    Rectangle {
                        anchors.centerIn: parent
                        width: 9
                        height: 9
                        radius: 6
                        color: DexTheme.accentColor
                    }
                }
            }

            DexRectangle {
                id: bg
                width: content_column.width
                readonly property int row_height: 40
                Layout.minimumHeight: row_height
                Layout.preferredHeight: row_height * Math.min(wallets.length, 3)
                color: "transparent"
                DefaultListView {
                    id: list
                    implicitHeight: bg.Layout.preferredHeight

                    model: wallets

                    delegate: ClipRRect {
                        radius: 5
                        width: bg.width
                        height: bg.row_height
                        DexRectangle {

                            color: "transparent"
                            border.width: 0

                            anchors.fill: parent

                            Rectangle {
                                height: parent.height
                                width: mouse_area.containsMouse ? parent.width : 0
                                opacity: .4
                                Behavior on width {
                                    NumberAnimation {
                                        duration: 250
                                    }
                                }
                                color: DexTheme.buttonColorHovered
                                visible: mouse_area.containsMouse
                            }
                            DefaultMouseArea {
                                id: mouse_area
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    selected_wallet_name = model.modelData
                                    bottomDrawer.open()
                                }
                            }

                            Qaterial.ColorIcon {
                                anchors.verticalCenter: parent.verticalCenter
                                color: DexTheme.foregroundColor
                                source: Qaterial.Icons.account
                                iconSize: 16
                                x: 20
                            }
                            DefaultText {
                                anchors.left: parent.left
                                anchors.leftMargin: 45

                                text_value: model.modelData
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: Style.textSizeSmall2
                            }
                        }
                        Item {
                            anchors.right: parent.right
                            anchors.margins: 10
                            height: parent.height
                            width: 30
                            Qaterial.ColorIcon {
                                source: Qaterial.Icons.delete_
                                iconSize: 18
                                anchors.centerIn: parent
                                opacity: .8
                                color: _deleteArea.containsMouse ? DexTheme.redColor : DexTheme.foregroundColor
                            }
                            DexMouseArea {
                                id: _deleteArea
                                hoverEnabled: true
                                anchors.fill: parent
                                onClicked: {
                                    let wallet_name = model.modelData
                                    let dialog = app.getText({
                                        "title": qsTr("Delete") + " %1 ".arg(wallet_name) + ("wallet?"),
                                        text: qsTr("Enter password to confirm deletion of") + " %1 ".arg(wallet_name) + qsTr("wallet"),
                                        standardButtons: Dialog.Yes | Dialog.Cancel,
                                        warning: true,
                                        width: 300,
                                        iconColor: DexTheme.redColor,
                                        isPassword: true,
                                        placeholderText: qsTr("Type password"),
                                        yesButtonText: qsTr("Delete"),
                                        cancelButtonText: qsTr("Cancel"),
                                        onAccepted: function(text) {
                                            if (API.app.wallet_mgr.confirm_password(wallet_name, text)) {
                                                API.app.wallet_mgr.delete_wallet(wallet_name);
                                                app.showText({
                                                    title: qsTr("Wallet status"),
                                                    text: "%1 ".arg(wallet_name) + qsTr("wallet deleted successfully"),
                                                    standardButtons: Dialog.Ok
                                                })
                                                _setup.wallets = API.app.wallet_mgr.get_wallets()
                                            } else {
                                                app.showText({
                                                    title: qsTr("Wallet status"),
                                                    text: "%1 ".arg(wallet_name) + qsTr("wallet password entered is incorrect"),
                                                    iconSource: Qaterial.Icons.alert,
                                                    iconColor: DexTheme.redColor,
                                                    warning: true,
                                                    standardButtons: Dialog.Ok
                                                })
                                            }
                                            dialog.close()
                                            dialog.destroy()
                                        }

                                    })
                                }
                            }
                        }
                    }
                }
            }
        }



        HorizontalLine {
            light: true
        }

    }
    Component.onCompleted: {
        updateWallets()
    }
    Connections {
        target: app
        function onCan_open_loginChanged() {
            console.log("LOGIN STATE changed")
            if (app.can_open_login) {
                bottomDrawer.open()
                app.can_open_login = false
            }
        }
    }
    GaussianBlur {
        anchors.fill: _setup
        visible: false
        source: _setup
        radius: 21
        deviation: 2
    }
    RecursiveBlur {
        visible: bottomDrawer.y === 0 && bottomDrawer.visible
        anchors.fill: _setup
        source: _setup
        radius: 2
        loops: 120
    }



    bottom_content: LinksRow {
        visible: !(bottomDrawer.y === 0 && bottomDrawer.visible)
    }
}