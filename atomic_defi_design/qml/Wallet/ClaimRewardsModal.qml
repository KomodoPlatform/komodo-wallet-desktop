import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

BasicModal {
    id: root

    readonly property bool empty_data: !prepare_claim_rewards_result || !prepare_claim_rewards_result.withdraw_answer
    readonly property bool positive_claim_amount: empty_data ? false :
                                                parseFloat(prepare_claim_rewards_result.withdraw_answer.my_balance_change) > 0
    readonly property bool has_eligible_utxo: {
        if(empty_data) return false
        const utxos = prepare_claim_rewards_result.kmd_rewards_info.result
        if(!utxos) return false

        for(let i = 0; i < utxos.length; ++i)
            if(!utxos[i].accrued_rewards.NotAccruedReason)
                return true

        return false
    }

    readonly property var default_prepare_claim_rewards_result: ({
         "kmd_rewards_info": {
             "result": [
                 {
                     "accrue_start_at": 1596785618,
                     "accrue_stop_at": 1599460418,
                     "accrue_start_at_human_date": "7 Aug 2020, 08:33",
                     "accrue_stop_at_human_date": "7 Sep 2020, 08:33",
                     "accrued_rewards": {
                         "Accrued": "0"
                     },
                     "amount": "0",
                     "output_index": 0
                 }
             ]
         },
         "withdraw_answer": {
             "fee_details": {
                 "amount": "0.00001"
             },
             "date": "7 Aug 2020, 08:33",
             "my_balance_change": "0",
             "tx_hash": "",
             "tx_hex": ""
         }
     })
    property var prepare_claim_rewards_result: General.clone(default_prepare_claim_rewards_result)

    // Override
    property var postClaim: () => {}

    // Local
    readonly property bool can_confirm: positive_claim_amount && has_eligible_utxo && !is_broadcast_busy

    readonly property bool can_claim: current_ticker_infos.is_claimable && !api_wallet_page.is_claiming_busy
    readonly property var claim_rpc_result: api_wallet_page.claiming_rpc_data

    readonly property bool is_broadcast_busy: api_wallet_page.is_broadcast_busy
    readonly property string broadcast_result: api_wallet_page.broadcast_rpc_data

    onClaim_rpc_resultChanged: {
        prepare_claim_rewards_result = General.clone(claim_rpc_result)
        if(!prepare_claim_rewards_result.withdraw_answer) {
            reset()
            return
        }

        console.log("Claim rewards result changed:", JSON.stringify(prepare_claim_rewards_result))

        if(prepare_claim_rewards_result.error_code) {
            toast.show(qsTr("Failed to prepare to claim rewards"), General.time_toast_important_error, prepare_claim_rewards_result.error_message)
            root.close()
        }
    }

    onBroadcast_resultChanged: {
        if(root.visible && broadcast_result !== "") {
            root.currentIndex = 1
            postClaim()
        }
    }

    function prepareClaimRewards() {
        if(!can_claim) return

        root.currentIndex = 0
        reset()

        api_wallet_page.claim_rewards()
    }

    function claimRewards() {
        api_wallet_page.broadcast(prepare_claim_rewards_result.withdraw_answer.tx_hex, true, false, "0")
    }

    function reset() {
        prepare_claim_rewards_result = General.clone(default_prepare_claim_rewards_result)
    }

    // Inside modal
    width: 1200
    ModalContent {
        title: qsTr("Claim your %1 reward?", "TICKER").arg(api_wallet_page.ticker)

        DefaultBusyIndicator {
            visible: !can_claim || is_broadcast_busy
            Layout.alignment: Qt.AlignCenter
        }

        RowLayout {
            visible: can_claim

            Layout.fillWidth: true
            DexLabel {
                Layout.fillWidth: true
                text_value: !has_eligible_utxo ? ("❌ " + qsTr("No UTXOs eligible for claiming")) :
                            !positive_claim_amount ? ("❌ " + qsTr("Transaction fee is higher than the reward!")) :

                            qsTr("You will receive %1", "AMT TICKER").arg(General.formatCrypto("", prepare_claim_rewards_result.withdraw_answer.my_balance_change, api_wallet_page.ticker))
            }

            PrimaryButton {
                text: qsTr("Refresh")
                onClicked: prepareClaimRewards()

                enabled: can_claim
            }
        }

        DefaultText {
            text_value: General.cex_icon + ' <a href="https://support.komodoplatform.com/support/solutions/articles/29000024428-komodo-5-active-user-reward-all-you-need-to-know">' + qsTr('Read more about KMD active users rewards') + '</a>'
            font.pixelSize: Style.textSizeSmall2
        }

        // List header
        Item {
            visible: can_claim

            Layout.topMargin: 25
            Layout.fillWidth: true

            height: 40

            // Price
            DefaultText {
                id: utxo_header
                font.pixelSize: Style.textSizeSmall4

                text_value: qsTr("UTXO")

                font.weight: Font.Medium
                horizontalAlignment: Text.AlignLeft

                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.000

                anchors.verticalCenter: parent.verticalCenter
            }

            // Amount
            DefaultText {
                id: amount_header

                text_value: qsTr("Amount")

                font.pixelSize: utxo_header.font.pixelSize
                font.weight: utxo_header.font.weight
                horizontalAlignment: utxo_header.horizontalAlignment

                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.060

                anchors.verticalCenter: parent.verticalCenter
            }

            // Reward
            DefaultText {
                id: reward_header

                text_value: qsTr("Reward")

                font.pixelSize: utxo_header.font.pixelSize
                font.weight: utxo_header.font.weight
                horizontalAlignment: Text.AlignLeft

                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.225

                anchors.verticalCenter: parent.verticalCenter
            }

            // Accruing start
            DefaultText {
                id: accruing_start_header

                text_value: qsTr("Accruing Start")

                font.pixelSize: utxo_header.font.pixelSize
                font.weight: utxo_header.font.weight
                horizontalAlignment: Text.AlignLeft

                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.400

                anchors.verticalCenter: parent.verticalCenter
            }

            // Accruing Stop
            DefaultText {
                id: accruing_stop_header

                text_value: qsTr("Accruing Stop")

                font.pixelSize: utxo_header.font.pixelSize
                font.weight: utxo_header.font.weight
                horizontalAlignment: Text.AlignLeft

                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.550

                anchors.verticalCenter: parent.verticalCenter
            }

            // Time Left
            DefaultText {
                id: time_left_header

                text_value: qsTr("Time Left")

                font.pixelSize: utxo_header.font.pixelSize
                font.weight: utxo_header.font.weight
                horizontalAlignment: Text.AlignLeft

                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.700

                anchors.verticalCenter: parent.verticalCenter
            }

            // Error
            DefaultText {
                id: error_header

                text_value: qsTr("Error")

                font.pixelSize: utxo_header.font.pixelSize
                font.weight: utxo_header.font.weight
                horizontalAlignment: Text.AlignLeft

                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.820

                anchors.verticalCenter: parent.verticalCenter
            }

            // Line
            HorizontalLine {
                width: parent.width
                color: Style.colorWhite5
                anchors.bottom: parent.bottom
            }
        }

        DefaultListView {
            visible: can_claim

            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 500
            clip: true

            model: empty_data ? [] :
                    prepare_claim_rewards_result.kmd_rewards_info.result

            delegate: Item {
                width: root.width
                height: utxo_value.font.pixelSize * 1.5

                // UTXO
                DefaultText {
                    id: utxo_value

                    anchors.left: parent.left
                    anchors.leftMargin: utxo_header.anchors.leftMargin

                    font.pixelSize: utxo_header.font.pixelSize

                    text_value: "#" + (index + 1)
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Amount
                DefaultText {
                    id: amount_value

                    anchors.left: parent.left
                    anchors.leftMargin: amount_header.anchors.leftMargin

                    font.pixelSize: utxo_value.font.pixelSize

                    text_value: modelData.amount
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Reward
                DefaultText {
                    id: reward_value

                    anchors.left: parent.left
                    anchors.leftMargin: reward_header.anchors.leftMargin

                    font.pixelSize: utxo_value.font.pixelSize

                    text_value: modelData.accrued_rewards.Accrued || "-"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Accruing Start
                DefaultText {
                    id: accruing_start_value

                    anchors.left: parent.left
                    anchors.leftMargin: accruing_start_header.anchors.leftMargin

                    font.pixelSize: utxo_value.font.pixelSize

                    text_value: modelData.accrue_start_at_human_date || "-"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Accruing Stop
                DefaultText {
                    id: accruing_stop_value

                    anchors.left: parent.left
                    anchors.leftMargin: accruing_stop_header.anchors.leftMargin

                    font.pixelSize: utxo_value.font.pixelSize

                    text_value: modelData.accrue_stop_at_human_date || "-"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Time Left
                DefaultText {
                    id: time_left_value

                    anchors.left: parent.left
                    anchors.leftMargin: time_left_header.anchors.leftMargin

                    font.pixelSize: utxo_value.font.pixelSize

                    text_value: modelData.accrue_stop_at ? General.secondsToTimeLeft(Date.now()/1000, modelData.accrue_stop_at) : '-'
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Error
                DefaultText {
                    id: error_value

                    anchors.left: parent.left
                    anchors.leftMargin: error_header.anchors.leftMargin

                    font.pixelSize: utxo_value.font.pixelSize

                    text_value: {
                        let val = modelData.accrued_rewards.NotAccruedReason
                        if(val === null || val === undefined) return "-"

                        switch(val) {
                        case "LocktimeNotSet":
                            val = qsTr("Locktime is not set")
                            break
                        case "LocktimeLessThanThreshold":
                            val = qsTr("Locktime is less than the threshold")
                            break
                        case "UtxoHeightGreaterThanEndOfEra":
                            val = qsTr("UTXO height is greater than end of the era")
                            break
                        case "UtxoAmountLessThanTen":
                            val = qsTr("UTXO amount is less than 10")
                            break
                        case "OneHourNotPassedYet":
                            val = qsTr("One hour did not pass yet")
                            break
                        case "TransactionInMempool":
                            val = qsTr("Transaction is in mempool")
                            break
                        default:
                            val = qsTr("Unknown problem")
                            break
                        }

                        return "❌ " + val
                    }

                    anchors.verticalCenter: parent.verticalCenter
                }

                // Line
                HorizontalLine {
                    visible: empty_data ? false :
                             prepare_claim_rewards_result.kmd_rewards_info.result &&
                             index !== prepare_claim_rewards_result.kmd_rewards_info.result.length - 1
                    width: parent.width
                    color: Style.colorWhite9
                    anchors.bottom: parent.bottom
                }
            }
        }

        // Buttons
        footer: [
            DexAppButton {
                text: qsTr("Cancel")
                leftPadding: 40
                rightPadding: 40
                radius: 18
                onClicked: root.close()
            },

            Item {
                Layout.fillWidth: true
            },

            DexAppOutlineButton {
                text: qsTr("Confirm")
                leftPadding: 40
                rightPadding: 40
                radius: 18
                opacity: enabled ? containsMouse ? .7 : 1 : .5
                onClicked: claimRewards()
                enabled: can_confirm
            }
        ]
    }

    // Result Page
    SendResult {
        result: ({
            balance_change: empty_data ? "" : prepare_claim_rewards_result.withdraw_answer.my_balance_change,
            fees: empty_data ? "" : prepare_claim_rewards_result.withdraw_answer.fee_details.amount,
            date: empty_data ? "" : prepare_claim_rewards_result.withdraw_answer.date
        })
        tx_hash: broadcast_result

        function onClose() { root.close() }
    }
}
