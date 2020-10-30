import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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

    function loadingPercentage(remaining) {
        return General.formatPercent((100 * (1 - parseFloat(remaining)/parseFloat(current_ticker_infos.current_block))).toFixed(3), false)
    }

    readonly property var transactions_mdl: api_wallet_page.transactions_mdl

    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout {
        id: wallet_layout

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: layout_margin
        anchors.bottom: parent.bottom

        spacing: 30

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
                        source: General.coinIcon(api_wallet_page.ticker)
                        Layout.preferredHeight: 60
                        Layout.preferredWidth: Layout.preferredHeight
                    }

                    // Name and crypto amount
                    ColumnLayout {
                        id: balance_layout
                        spacing: 3

                        DefaultText {
                            id: name
                            text_value: current_ticker_infos.name
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: Style.textSizeMid
                        }

                        DefaultText {
                            id: name_value
                            text_value: General.formatCrypto("", current_ticker_infos.balance, api_wallet_page.ticker)
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
                        text_value: qsTr("Wallet Balance")
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        color: price.color
                    }

                    DefaultText {
                        text_value: General.formatFiat("", current_ticker_infos.fiat_amount, API.app.settings_pg.current_currency)
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
                        text_value: qsTr("Price")
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        color: Style.colorText2
                    }

                    DefaultText {
                        text_value: General.formatFiat('', current_ticker_infos.current_currency_ticker_price, API.app.settings_pg.current_currency)
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                    }
                }

                // Change 24h
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DefaultText {
                        text_value: qsTr("Change 24h")
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        color: price.color
                    }

                    DefaultText {
                        text_value: {
                            const v = parseFloat(current_ticker_infos.change_24h)
                            return v === 0 ? '-' : General.formatPercent(v)
                        }
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        color: Style.getValueColor(current_ticker_infos.change_24h)
                    }
                }

                // Portfolio %
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DefaultText {
                        text_value: qsTr("Portfolio %")
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        color: price.color
                    }

                    DefaultText {
                        text_value: {
                            const fiat_amount = parseFloat(current_ticker_infos.fiat_amount)
                            const portfolio_balance = parseFloat(API.app.portfolio_pg.balance_fiat_all)
                            if(fiat_amount <= 0 || portfolio_balance <= 0) return "-"

                            return General.formatPercent((100 * fiat_amount/portfolio_balance).toFixed(2), false)
                        }
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        privacy: true
                    }
                }
            }
        }

        // Address Book, Send, Receive buttons
        RowLayout {
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 25

            DefaultButton {
                id: send_button
                enabled: parseFloat(current_ticker_infos.balance) > 0
                text: qsTr("Send")
                onClicked: send_modal.open()
                Layout.fillWidth: true
                font.pixelSize: Style.textSize

                Arrow {
                    id: arrow_send
                    up: true
                    color: Style.colorGreen
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                }
            }

            SendModal {
                id: send_modal
            }

            DefaultButton {
                text: qsTr("Receive")
                onClicked: receive_modal.open()
                Layout.fillWidth: true
                font.pixelSize: send_button.font.pixelSize

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
                visible: !is_dex_banned
                text: qsTr("Swap")
                onClicked: onClickedSwap()
                Layout.fillWidth: true
                font.pixelSize: send_button.font.pixelSize

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
                text: qsTr("Claim Rewards")
                Layout.fillWidth: true
                font.pixelSize: send_button.font.pixelSize

                visible: current_ticker_infos.is_claimable && !API.app.is_pin_cfg_enabled()
                enabled: parseFloat(current_ticker_infos.balance) > 0
                onClicked: {
                    claim_rewards_modal.prepareClaimRewards()
                    claim_rewards_modal.open()
                }
            }

            ClaimRewardsModal {
                id: claim_rewards_modal
            }

            // Faucet for RICK/MORTY coins
            PrimaryButton {
                id: button_claim_faucet
                text: qsTr("Faucet")
                Layout.fillWidth: true
                font.pixelSize: send_button.font.pixelSize
                enabled: parseFloat(current_ticker_infos.balance) > 0
                visible: enabled && current_ticker_infos.is_test_coin

                onClicked: {
                    api_wallet_page.claim_faucet()
                }

                ClaimFaucetResultModal {}
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

            visible: chart.has_data

            PriceGraph {
                id: chart
                anchors.fill: parent

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

                            content: DefaultImage {
                                source: General.image_path + "shadowed_circle_green.svg"

                                width: 12; height: width
                            }
                        }

                        DefaultText {
                            id: left_text
                            text_value: qsTr("%1 / %2 Price", "TICKER").arg(api_wallet_page.ticker).arg(API.app.settings_pg.current_fiat) + " " + General.cex_icon
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

                            content: DefaultImage {
                                source: General.image_path + "shadowed_circle_blue.svg"

                                width: 12; height: width
                            }
                        }

                        DefaultText {
                            text_value: qsTr("Volume 24h") + " (" + API.app.settings_pg.current_fiat + ")"
                            font: left_text.font
                        }
                    }
                }
            }
        }

        // Transactions or loading
        Item {
            id: loading_tx
            visible: current_ticker_infos.tx_state === "InProgress"
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            implicitHeight: 100

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                DefaultText {
                    text_value: qsTr("Loading")
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Style.textSize2
                }

                DefaultBusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                }

                DefaultText {
                    text_value: General.isTokenType(current_ticker_infos.type) ?
                                (qsTr("Scanning blocks for TX History...") + " " + loadingPercentage(current_ticker_infos.blocks_left)) :
                                (qsTr("Syncing TX History...") + " " + loadingPercentage(current_ticker_infos.transactions_left))

                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Separator line
        HorizontalLine {
            visible: loading_tx.visible && transactions_mdl.length > 0
            width: 720
            Layout.alignment: Qt.AlignHCenter
        }

        InnerBackground {
            id: transactions_bg
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin
            Layout.bottomMargin: !fetching_text_row.visible ? layout_margin : undefined

            implicitHeight: wallet.height*0.54

            content: Item {
                width: transactions_bg.width
                height: transactions_bg.height

                DefaultText {
                    anchors.centerIn: parent
                    visible: current_ticker_infos.tx_state !== "InProgress" && transactions_mdl.length === 0
                    text_value: api_wallet_page.tx_fetching_busy ? (qsTr("Refreshing") + "...") : qsTr("No transactions")
                    font.pixelSize: Style.textSize
                    color: Style.colorWhite4
                }

                Transactions {
                    width: parent.width
                    height: parent.height
                    model: transactions_mdl.proxy_mdl
                }
            }
        }

        RowLayout {
            id: fetching_text_row
            visible: api_wallet_page.tx_fetching_busy
            Layout.preferredHeight: fetching_text.font.pixelSize * 1.5

            Layout.topMargin: -layout_margin*0.5
            Layout.bottomMargin: layout_margin*0.5

            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            DefaultBusyIndicator {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Style.textSizeSmall3
                Layout.preferredHeight: Layout.preferredWidth
            }

            DefaultText {
                id: fetching_text
                Layout.alignment: Qt.AlignVCenter
                text_value: qsTr("Fetching transactions") + "..."
                font.pixelSize: Style.textSizeSmall3
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
