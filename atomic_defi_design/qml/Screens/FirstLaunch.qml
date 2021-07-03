import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import "../Settings"

SetupPage {
    // Override
    property var onClickedNewUser: () => {}
    property var onClickedRecoverSeed: () => {}
    property var onClickedWallet: () => {}

    Component.onCompleted: updateWallets()

    // Local
    function updateWallets() {
        wallets = API.app.wallet_mgr.get_wallets()
    }

    property var wallets: ([])

    image_path: "file:///" + atomic_logo_path +  "/" + theme.bigSidebarLogo
    image_margin: 30
    content: ColumnLayout {
        id: content_column
        width: 400
        spacing: Style.rowSpacing
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
                        width: bg.width
                        height: bg.row_height
                        GradientRectangle {
                            start_color: Style.applyOpacity(Style.colorWalletsHighlightGradient, mouse_area.containsMouse ? "80" : "00")
                            end_color:  Style.applyOpacity(Style.colorWalletsHighlightGradient)

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
                                    onClickedWallet()
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
                                visible: index !== wallets.length -1
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



    bottom_content: LinksRow {}
}
