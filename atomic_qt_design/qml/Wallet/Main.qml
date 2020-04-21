import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Right side, main
Item {
    property alias send_modal: send_modal

    function reset() {
        send_modal.reset(true)
        receive_modal.reset()
        claim_rewards_modal.reset()
        transactions.reset()
    }

    Layout.fillHeight: true
    Layout.fillWidth: true
    ColumnLayout {
        id: wallet_layout
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.bottom: parent.bottom

        spacing: 30

        // Balance box
        Rectangle {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius
            Layout.preferredWidth: balance_box_layout.childrenRect.width + 40
            Layout.preferredHeight: balance_box_layout.childrenRect.height + 40

            RowLayout {
                id: balance_box_layout
                anchors.centerIn: parent

                Image {
                    source: General.coinIcon(API.get().current_coin_info.ticker)
                    Layout.rightMargin: 10
                    Layout.preferredHeight: balance_layout.childrenRect.height
                    Layout.preferredWidth: Layout.preferredHeight
                }

                ColumnLayout {
                    id: balance_layout
                    DefaultText {
                        text: API.get().empty_string + (General.formatCrypto("", API.get().current_coin_info.balance, API.get().current_coin_info.ticker))
                        Layout.alignment: Qt.AlignRight
                        font.pixelSize: Style.textSize5
                    }

                    DefaultText {
                        text: API.get().empty_string + (General.formatFiat("", API.get().current_coin_info.fiat_amount, API.get().fiat))
                        Layout.topMargin: -15
                        Layout.rightMargin: 4
                        Layout.alignment: Qt.AlignRight
                        font.pixelSize: Style.textSize2
                        color: Style.colorWhite4
                    }
                }
            }
        }

        // Send, Receive buttons at top
        RowLayout {
            width: parent.width * 0.6

            Layout.topMargin: -10
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            spacing: 50

            DefaultButton {
                enabled: API.get().current_coin_info.tx_state !== "InProgress"
                text: API.get().empty_string + (qsTr("Send"))
                leftPadding: parent.width * button_margin
                rightPadding: leftPadding
                onClicked: send_modal.open()
            }

            SendModal {
                id: send_modal
            }

            DefaultButton {
                text: API.get().empty_string + (qsTr("Receive"))
                leftPadding: parent.width * button_margin
                rightPadding: leftPadding
                onClicked: receive_modal.open()
            }

            ReceiveModal {
                id: receive_modal
            }

            DefaultButton {
                text: API.get().empty_string + (qsTr("Swap"))
                leftPadding: parent.width * button_margin
                rightPadding: leftPadding
                onClicked: onClickedSwap()
            }

            PrimaryButton {
                id: button_claim_rewards
                text: API.get().empty_string + (qsTr("Claim Rewards"))
                leftPadding: parent.width * button_margin
                rightPadding: leftPadding

                visible: API.get().current_coin_info.is_claimable === true
                enabled: API.get().current_coin_info.tx_state !== "InProgress" && claim_rewards_modal.canClaim()
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
            width: 720
            Layout.alignment: Qt.AlignHCenter
        }

        DefaultText {
            visible: API.get().current_coin_info.tx_state !== "InProgress" && API.get().current_coin_info.transactions.length === 0
            text: API.get().empty_string + (qsTr("No transactions"))
            font.pixelSize: Style.textSize
            color: Style.colorWhite4
            Layout.alignment: Qt.AlignHCenter
        }


        // Transactions or loading
        Rectangle {
            id: loading_tx
            color: "transparent"
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

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                }

                DefaultText {
                    text: API.get().empty_string + (qsTr("Syncing %n TX(s)...", "", parseInt(API.get().current_coin_info.tx_current_block)))
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Separator line
        HorizontalLine {
            visible: loading_tx.visible && transactions.model.length > 0
            width: 720
            Layout.alignment: Qt.AlignHCenter
        }

        Transactions {
            id: transactions
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: Math.min(contentItem.childrenRect.height, wallet.height*0.5)
        }

        implicitHeight: Math.min(contentItem.childrenRect.height, wallet.height*0.5)
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
