import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Right side, main
Item {
    property alias send_modal: send_modal
    readonly property int layout_margin: 30

    function openAddressBook() {
        main_layout.currentIndex = 1
    }

    function closeAddressBook() {
        main_layout.currentIndex = 0
    }

    function reset() {
        send_modal.reset(true)
        receive_modal.reset()
        claim_rewards_modal.reset()
    }

    function loadingPercentage(remaining) {
        return General.formatPercent((100 * (1 - parseFloat(remaining)/parseFloat(API.get().current_coin_info.tx_current_block))).toFixed(3), false)
    }

    Layout.fillHeight: true
    Layout.fillWidth: true

    StackLayout {
        id: main_layout

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: layout_margin
        anchors.bottom: parent.bottom

        ColumnLayout {
            id: wallet_layout

            spacing: 20

            // Balance box
            FloatingBackground {
                id: balance_box
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.leftMargin: layout_margin
                Layout.rightMargin: layout_margin

                content: RowLayout {
                    width: balance_box.width

                    RowLayout {
                        Layout.alignment: Qt.AlignLeft
                        Layout.topMargin: 12
                        Layout.bottomMargin: Layout.topMargin
                        Layout.leftMargin: 15
                        spacing: 15
                        // Icon
                        DefaultImage {
                            source: General.coinIcon(API.get().current_coin_info.ticker)
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: Layout.preferredHeight
                        }

                        // Name and crypto amount
                        ColumnLayout {
                            id: balance_layout
                            spacing: -2

                            DefaultText {
                                id: name
                                text_value: API.get().empty_string + (API.get().current_coin_info.name)
                                Layout.alignment: Qt.AlignLeft
                                font.pixelSize: Style.textSizeMid
                            }

                            DefaultText {
                                id: name_value
                                text_value: API.get().empty_string + (General.formatCrypto("", API.get().current_coin_info.balance, API.get().current_coin_info.ticker))
                                Layout.alignment: Qt.AlignLeft
                                font.pixelSize: name.font.pixelSize
                                privacy: true
                            }
                        }
                    }

                    // Wallet Balance
                    ColumnLayout {
                        Layout.alignment: Qt.AlignLeft
                        spacing: balance_layout.spacing
                        DefaultText {
                            text_value: API.get().empty_string + (qsTr("Wallet Balance"))
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            color: price.color
                        }

                        DefaultText {
                            text_value: API.get().empty_string + (General.formatFiat("", API.get().current_coin_info.fiat_amount, API.get().current_currency))
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            privacy: true
                        }
                    }

                    VerticalLine {
                        Layout.alignment: Qt.AlignLeft
                        Layout.rightMargin: 30
                        height: balance_layout.height * 0.8
                        color: Style.colorThemeDarkLight
                    }

                    // Price
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: balance_layout.spacing
                        DefaultText {
                            id: price
                            text_value: API.get().empty_string + (qsTr("Price"))
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            color: Style.colorText2
                        }

                        DefaultText {
                            text_value: API.get().empty_string + (General.formatFiat('', API.get().current_coin_info.main_currency_balance, API.get().current_currency))
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                        }
                    }

                    // Change 24h
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: balance_layout.spacing
                        DefaultText {
                            text_value: API.get().empty_string + (qsTr("Change 24h"))
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            color: price.color
                        }

                        DefaultText {
                            text_value: {
                                const v = parseFloat(API.get().current_coin_info.change_24h)
                                return API.get().empty_string + (v === 0 ? '-' : General.formatPercent(v))
                            }
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            color: Style.getValueColor(API.get().current_coin_info.change_24h)
                        }
                    }

                    // Portfolio %
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: balance_layout.spacing
                        DefaultText {
                            text_value: API.get().empty_string + (qsTr("Portfolio %"))
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            color: price.color
                        }

                        DefaultText {
                            text_value: {
                                const fiat_amount = parseFloat(API.get().current_coin_info.fiat_amount)
                                const portfolio_balance = parseFloat(API.get().balance_fiat_all)
                                if(fiat_amount <= 0 || portfolio_balance <= 0) return "-"

                                return API.get().empty_string + (General.formatPercent((100 * fiat_amount/portfolio_balance).toFixed(2), false))
                            }
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            privacy: true
                        }
                    }
                }
            }

            InnerBackground {
                id: price_graph_bg
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: layout_margin
                Layout.rightMargin: layout_margin
                Layout.bottomMargin: -parent.spacing*0.5
                implicitHeight: wallet.height*0.6

                content: PriceGraph {
                    width: price_graph_bg.width
                    height: price_graph_bg.height

                    RowLayout {
                        spacing: 60
                        y: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft

                            FloatingBackground {
                                id: left_circle

                                verticalShadow: true
                                width: 28; height: 28
                                radius: 100

                                content: DefaultImage {
                                    source: General.image_path + "shadowed_circle_green.svg"

                                    width: 12; height: width
                                }
                            }

                            DefaultText {
                                id: left_text
                                text_value: API.get().empty_string + (qsTr("%1 / %2 Price", "TICKER").arg(API.get().current_coin_info.ticker).arg(API.get().current_fiat) + " " + General.cex_icon)
                                font.pixelSize: Style.textSizeSmall3

                                CexInfoTrigger {}
                            }
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            Layout.fillWidth: true

                            FloatingBackground {
                                verticalShadow: left_circle.verticalShadow
                                width: left_circle.width; height: left_circle.height
                                radius: 100

                                content: DefaultImage {
                                    source: General.image_path + "shadowed_circle_blue.svg"

                                    width: 12; height: width
                                }
                            }

                            DefaultText {
                                text_value: API.get().empty_string + (qsTr("Volume 24h") + " (" + API.get().current_fiat + ")")
                                font: left_text.font
                            }
                        }
                    }
                }
            }

            // Address Book, Send, Receive buttons
            RowLayout {
                Layout.preferredWidth: main_layout.width
                Layout.bottomMargin: -parent.spacing*0.5
                Layout.leftMargin: layout_margin
                Layout.rightMargin: layout_margin

                spacing: 15

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 15

                    DefaultButton {
                        text: API.get().empty_string + (qsTr("Address Book"))
                        onClicked: openAddressBook()
                    }

                    DefaultButton {
                        enabled: parseFloat(API.get().current_coin_info.balance) > 0
                        text: API.get().empty_string + (qsTr("Send"))
                        onClicked: send_modal.open()
                        text_offset: -arrow_send.anchors.rightMargin
                        text_left_align: true

                        Arrow {
                            id: arrow_send
                            up: true
                            color: Style.colorGreen
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                        }
                    }

                    SendModal {
                        id: send_modal
                    }

                    DefaultButton {
                        text: API.get().empty_string + (qsTr("Receive"))
                        onClicked: receive_modal.open()
                        text_offset: -arrow_send.anchors.rightMargin
                        text_left_align: true

                        Arrow {
                            up: false
                            color: Style.colorBlue
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: arrow_send.anchors.rightMargin
                        }
                    }

                    ReceiveModal {
                        id: receive_modal
                    }

                    DefaultButton {
                        text: API.get().empty_string + (qsTr("Swap"))
                        onClicked: onClickedSwap()
                        text_offset: -arrow_send.anchors.rightMargin
                        text_left_align: true

                        Arrow {
                            up: true
                            color: Style.colorGreen
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: arrow_send.anchors.rightMargin*2.4
                        }

                        Arrow {
                            up: false
                            color: Style.colorBlue
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: arrow_send.anchors.rightMargin
                        }
                    }

                    PrimaryButton {
                        id: button_claim_rewards
                        text: API.get().empty_string + (qsTr("Claim Rewards"))

                        visible: API.get().current_coin_info.is_claimable === true
                        enabled: claim_rewards_modal.canClaim()
                        onClicked: {
                            claim_rewards_modal.prepareClaimRewards()
                            claim_rewards_modal.open()
                        }
                    }

                    ClaimRewardsModal {
                        id: claim_rewards_modal

                        postClaim: () => { button_claim_rewards.enabled = claim_rewards_modal.canClaim() }
                    }
                }
            }

            // Separator line
            HorizontalLine {
                Layout.fillWidth: true
                Layout.leftMargin: layout_margin
                Layout.rightMargin: layout_margin
                Layout.alignment: Qt.AlignHCenter
            }

            // Transactions or loading
            Item {
                id: loading_tx
                visible: API.get().current_coin_info.tx_state === "InProgress"
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                implicitHeight: 100

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    DefaultText {
                        text_value: API.get().empty_string + (qsTr("Loading"))
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Style.textSize2
                    }

                    DefaultBusyIndicator {
                        Layout.alignment: Qt.AlignHCenter
                    }

                    DefaultText {
                        text_value: API.get().empty_string + (
                          API.get().current_coin_info.type === "ERC-20" ?
                          (qsTr("Scanning blocks for TX History...") + " " + loadingPercentage(API.get().current_coin_info.blocks_left)) :
                          (qsTr("Syncing TX History...") + " " + loadingPercentage(API.get().current_coin_info.transactions_left))
                        )
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Separator line
            HorizontalLine {
                visible: loading_tx.visible && API.get().current_coin_info.transactions.length > 0
                width: 720
                Layout.alignment: Qt.AlignHCenter
            }

            InnerBackground {
                id: transactions_bg
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: layout_margin
                Layout.rightMargin: layout_margin
                Layout.bottomMargin: layout_margin

                implicitHeight: wallet.height*0.54

                content: Item {
                    width: transactions_bg.width
                    height: transactions_bg.height

                    DefaultText {
                        anchors.centerIn: parent
                        visible: API.get().current_coin_info.tx_state !== "InProgress" && API.get().current_coin_info.transactions.length === 0
                        text_value: API.get().empty_string + (qsTr("No transactions"))
                        font.pixelSize: Style.textSize
                        color: Style.colorWhite4
                    }

                    Transactions {
                        width: parent.width
                        height: parent.height
                    }
                }
            }

            implicitHeight: Math.min(contentItem.childrenRect.height, wallet.height*0.5)
        }

        AddressBook {

        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
