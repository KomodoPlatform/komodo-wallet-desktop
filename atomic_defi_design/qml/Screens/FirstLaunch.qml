import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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

    image_path: General.image_path + Style.sidebar_atomicdex_logo
    image_margin: 30
    content: ColumnLayout {
        id: content_column
        width: 400
        spacing: Style.rowSpacing
        DefaultText {
            text_value: qsTr("Welcome")
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.buttonSpacing

            DexButton {
                Layout.fillWidth: true
                text: qsTr("New Wallet")
                textScale: API.app.settings_pg.lang=="fr"? 0.82 : 0.99
                onClicked: onClickedNewUser()
            }

            DexButton {
                Layout.fillWidth: true
                text: qsTr("Recover Wallet")
                textScale: API.app.settings_pg.lang=="fr"? 0.82 : 0.99
                onClicked: onClickedRecoverSeed()
            }
        }

        // Wallets
        ColumnLayout {
            spacing: Style.rowSpacing

            visible: wallets.length > 0

            // Name
            DefaultText {
                text_value: qsTr("My Wallets")
                font.pixelSize: Style.textSizeSmall2
            }

            InnerBackground {
                id: bg
                width: content_column.width
                readonly property int row_height: 40
                Layout.minimumHeight: row_height
                Layout.preferredHeight: row_height * Math.min(wallets.length, 3)

                content: DefaultListView {
                    id: list
                    implicitHeight: bg.Layout.preferredHeight

                    model: wallets

                    delegate: GradientRectangle {
                        start_color: Style.applyOpacity(Style.colorWalletsHighlightGradient, mouse_area.containsMouse ? "80" : "00")
                        end_color:  Style.applyOpacity(Style.colorWalletsHighlightGradient)

                        width: bg.width
                        height: bg.row_height

                        // Click area
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
                        DefaultText {
                            anchors.left: parent.left
                            anchors.leftMargin: 40

                            text_value: model.modelData
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: Style.textSizeSmall2
                        }

                        HorizontalLine {
                            visible: index !== wallets.length -1
                            width: parent.width - 4

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -height/2
                            light: true
                        }
                    }
                }
            }
        }



        HorizontalLine {
            light: true
        }

        Languages {
            Layout.alignment: Qt.AlignHCenter
            show_label: false
        }
    }



    bottom_content: LinksRow {}
}
