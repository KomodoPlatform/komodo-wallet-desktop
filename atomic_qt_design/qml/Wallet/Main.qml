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

    function reset() {
        send_modal.reset(true)
        receive_modal.reset()
        claim_rewards_modal.reset()
    }

    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout {
        id: wallet_layout
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: layout_margin
        anchors.bottom: parent.bottom

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
                    Image {
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
                            text: API.get().empty_string + (API.get().current_coin_info.name)
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: Style.textSizeMid2
                        }

                        DefaultText {
                            id: name_value
                            text: API.get().empty_string + (General.formatCrypto("", API.get().current_coin_info.balance, API.get().current_coin_info.ticker))
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: name.font.pixelSize
                            font.weight: Font.Medium
                        }
                    }
                }

                // Wallet Balance
                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft
                    spacing: balance_layout.spacing
                    DefaultText {
                        text: API.get().empty_string + (qsTr("Wallet Balance"))
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        color: Style.colorThemePassive
                    }

                    DefaultText {
                        text: API.get().empty_string + (General.formatFiat("", API.get().current_coin_info.fiat_amount, API.get().fiat))
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        font.weight: name_value.font.weight
                    }
                }

                VerticalLine {
                    Layout.alignment: Qt.AlignLeft
                    Layout.rightMargin: 30
                    height: balance_layout.height * 0.8
                    color: Style.colorTheme5
                }

                // Price
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DefaultText {
                        id: price
                        text: API.get().empty_string + (qsTr("Price"))
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        font.weight: Font.Light
                        color: Style.colorThemePassive
                    }

                    DefaultText {
                        text: {
                            const c = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
                            if(c === undefined) return "-"

                            return API.get().empty_string + (General.formatFiat('', c.price, API.get().fiat))
                        }

                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        font.weight: name_value.font.weight
                    }
                }

                // Change 24h
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DefaultText {
                        text: API.get().empty_string + (qsTr("Change 24h"))
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        font.weight: price.font.weight
                        color: Style.colorThemePassive
                    }

                    DefaultText {
                        text: {
                            const c = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
                            if(c === undefined || c.rates === null) return "-"

                            return API.get().empty_string + (General.formatPercent(c.rates[API.get().fiat].percent_change_24h))
                        }
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        font.weight: name_value.font.weight
                        color: {
                            const c = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)

                            const def_color = Style.colorWhite4
                            if(c === undefined || c.rates === null) return def_color

                            const v = parseFloat(c.rates[API.get().fiat].percent_change_24h)
                            return v === 0 ? def_color : v > 0 ? Style.colorGreen : Style.colorRed
                        }
                    }
                }

                // Portfolio %
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DefaultText {
                        text: API.get().empty_string + (qsTr("Portfolio %"))
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        font.weight: price.font.weight
                        color: Style.colorThemePassive
                    }

                    DefaultText {
                        text: {
                            const c = General.getCoin(portfolio_coins, API.get().current_coin_info.ticker)
                            if(c === undefined || c.balance_fiat === null) return "-"
                            const portfolio_balance = API.get().balance_fiat_all
                            if(parseFloat(portfolio_balance) <= 0) return "-"

                            return API.get().empty_string + (General.formatPercent((100 * parseFloat(c.balance_fiat)/parseFloat(portfolio_balance)).toFixed(2), false))
                        }
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        font.weight: name_value.font.weight
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
            }
        }

        // Send, Receive buttons
        RowLayout {
            width: parent.width * 0.6

            Layout.bottomMargin: -parent.spacing*0.5
            Layout.rightMargin: layout_margin
            Layout.alignment: Qt.AlignRight

            spacing: 15

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
                    text: API.get().empty_string + (qsTr("Loading"))
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Style.textSize2
                }

                DefaultBusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                }

                DefaultText {
                    text: API.get().empty_string + (
                      API.get().current_coin_info.type === "ERC-20" ?
                      (qsTr("Scanning blocks for TX History... %n block(s) left", "", parseInt(API.get().current_coin_info.blocks_left))) :
                      (qsTr("Syncing TX History... %n TX(s) left", "", parseInt(API.get().current_coin_info.transactions_left)))
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
                    text: API.get().empty_string + (qsTr("No transactions"))
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
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
