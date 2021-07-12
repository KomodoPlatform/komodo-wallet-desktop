import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import "../Settings"

SetupPage {
    // Override
    id: _setup
    property var onClickedNewUser: () => {}
    property var onClickedRecoverSeed: () => {}
    property var onClickedWallet: () => {}


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

    image_path: (bottomDrawer.y === 0 && bottomDrawer.visible) ? "" : "file:///" + atomic_logo_path + "/" + theme.bigSidebarLogo
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
                    source: "file:///" + atomic_logo_path + "/" + theme.bigSidebarLogo
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                DexLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "%1 wallet".arg(selected_wallet_name)
                    topPadding: 10
                }
                Connections {
                    target: bottomDrawer
                    function onVisibleChanged () {
                        _inputPassword.field.text = ""
                    }
                }
                DexAppTextField {
                    id: _inputPassword
                    height: 50
                    width: 300
                    anchors.horizontalCenter: parent.horizontalCenter
                    background.border.width: 1
                    background.radius: 25
                    field.echoMode: TextField.Password
                    field.font: field.echoMode === TextField.Password ? field.text === "" ? theme.textType.body1 : theme.textType.head5 : theme.textType.head6
                    field.horizontalAlignment: Qt.AlignLeft
                    field.leftPadding: 75
                    field.rightPadding: 60
                    field.placeholderText: qsTr("Type password")
                    field.onAccepted: {
                        if (_keyChecker.isValid()) {
                            if (onClickedLogin(field.text)) {
                                console.log("Okay")
                                bottomDrawer.close()
                                app.current_page = idx_initial_loading
                            } else {
                                error = true
                            }
                        } else {
                            error = true
                        }
                    }
                    DexRectangle {
                        x: 5
                        height: 40
                        width: 60
                        radius: 20
                        color: _inputPassword.field.focus ? _inputPassword.background.border.color : theme.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                        Qaterial.ColorIcon {
                            anchors.centerIn: parent
                            iconSize: 19
                            source: Qaterial.Icons.keyVariant
                            color: theme.surfaceColor
                        }

                    }
                    Qaterial.AppBarButton {
                        opacity: .8
                        icon {
                            source: _inputPassword.field.echoMode === TextField.Password ? Qaterial.Icons.eyeOffOutline : Qaterial.Icons.eyeOutline
                            color: _inputPassword.field.focus ? _inputPassword.background.border.color : theme.accentColor
                        }
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 10
                        }
                        onClicked: {
                            if (_inputPassword.field.echoMode === TextField.Password) {
                                _inputPassword.field.echoMode = TextField.Normal
                            } else {
                                _inputPassword.field.echoMode = TextField.Password
                            }
                        }
                    }
                }
                DexButton {
                    radius: width
                    width: 150
                    text: qsTr("connect")
                    color: theme.accentColor
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
                font: theme.textType.head6
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
            leftPadding: 10
            text: qsTr("New Wallet")
            Layout.preferredHeight: 50
            radius: 8
            backgroundColor: theme.accentColor
            onClicked: onClickedNewUser()
        }

        DexAppButton {
            text: qsTr("Recover Wallet")
            horizontalAlignment: Qt.AlignLeft
            backgroundColor: theme.accentColor
            leftPadding: 10
            radius: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            onClicked: onClickedRecoverSeed()
        }

        // Wallets
        ColumnLayout {
            spacing: Style.rowSpacing

            visible: wallets.length > 0

            // Name
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
                    color: theme.accentColor
                    Rectangle {
                        anchors.centerIn: parent
                        width: 9
                        height: 9
                        radius: 6
                        color: theme.accentColor
                    }
                }
            }

            DexRectangle {
                id: bg
                width: content_column.width
                readonly property int row_height: 40
                Layout.minimumHeight: row_height
                Layout.preferredHeight: row_height * Math.min(wallets.length, 3)

                DefaultListView {
                    id: list
                    implicitHeight: bg.Layout.preferredHeight

                    model: wallets

                    delegate: ClipRRect {
                        radius: 0
                        width: bg.width
                        height: bg.row_height
                        GradientRectangle {
                            start_color: Style.applyOpacity(Style.colorWalletsHighlightGradient, mouse_area.containsMouse ? "80" : "00")
                            end_color: Style.applyOpacity(Style.colorWalletsHighlightGradient)

                            anchors.fill: parent

                            // Click area
                            Rectangle {
                                height: parent.height
                                width: mouse_area.containsMouse ? parent.width : 0
                                opacity: .4
                                Behavior on width {
                                    NumberAnimation {
                                        duration: 250
                                    }
                                }
                                color: theme.accentColor
                                visible: mouse_area.containsMouse
                            }
                            DefaultMouseArea {
                                id: mouse_area
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    selected_wallet_name = model.modelData
                                    bottomDrawer.open()
                                    //onClickedWallet()
                                }
                            }

                            // Name
                            Qaterial.ColorIcon {
                                anchors.verticalCenter: parent.verticalCenter
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

                            HorizontalLine {
                                visible: index !== wallets.length - 1
                                width: parent.width - 4

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: -height / 2
                                light: true
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
        visible: false // bottomDrawer.y === 0 && bottomDrawer.visible
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