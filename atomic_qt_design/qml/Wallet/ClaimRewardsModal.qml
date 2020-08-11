import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    readonly property bool positive_claim_amount: parseFloat(prepare_claim_rewards_result.withdraw_answer.my_balance_change) > 0

    readonly property var default_prepare_claim_rewards_result: ({
         "kmd_rewards_info": {
             "result": [
                 {
                     "accrue_start_at": 1596785618,
                     "accrue_stop_at": 1599460418,
                     "accrue_start_at_human_date": " 7 Aug 2020, 08:33",
                     "accrue_stop_at_human_date": " 7 Sep 2020, 08:33",
                     "accrued_rewards": {
                         "Accrued": "0.04973265"
                     },
                     "amount": "103.62356229",
                     "output_index": 0
                 }
             ]
         },
         "withdraw_answer": {
             "fee_details": {
                 "amount": "0.00001"
             },
             "my_balance_change": "0.04972265",
             "tx_hash": "45f7a75e9782998f3a0809ea9ec8b68d3bdc438d34b6fc4114a6c8eddc3be6ae",
             "tx_hex": "0400008085202f8901bc8f81d43c4133f5ffe68d5f07c6dcf785d34b2bb184f91bdb6e990bd8ab0977000000006a473044022014b3f1dbca1e28c5958f94cf5d1aa97b3d49f53d2409baefb2cc882f3883eb3a02200d26f5deafdb6e0475d4b50764e1c77a69872413e75576beeba993a1d63225f3012102d4acb3b1cc944b8b44836c6a4ef87bdee906ce268465bde8106cfee171b7f40dffffffff01eee0f069020000001976a914eed5d3ad264ffc68fc0a6454e1696a30d8f405be88ac1aa3315f000000000000000000000000000000"
         }
     })
    property var prepare_claim_rewards_result: default_prepare_claim_rewards_result
    property string send_result

    // Override
    property var postClaim: () => {}

    // Local
    function canClaim() {
        return API.get().current_coin_info.is_claimable === true &&
                API.get().do_i_have_enough_funds(API.get().current_coin_info.ticker, API.get().current_coin_info.minimal_balance_for_asking_rewards) &&
                API.get().is_claiming_ready(API.get().current_coin_info.ticker)
    }

    function prepareClaimRewards() {
        stack_layout.currentIndex = 0
        reset()

        prepare_claim_rewards_result = API.get().claim_rewards(API.get().current_coin_info.ticker)
        console.log(JSON.stringify(prepare_claim_rewards_result))
        if(prepare_claim_rewards_result.withdraw_answer.error) {
            toast.show(qsTr("Failed to prepare to claim rewards"), General.time_toast_important_error, prepare_claim_rewards_result.withdraw_answer.error)
            return false
        }
        else if(prepare_claim_rewards_result.kmd_rewards_info.error) {
            toast.show(qsTr("Failed to get the rewards info"), General.time_toast_important_error, prepare_claim_rewards_result.kmd_rewards_info.error)
            return false
        }
        else {
            text_error.text = ""
            return true
        }
    }

    function claimRewards() {
        send_result = API.get().send_rewards(prepare_claim_rewards_result.withdraw_answer.tx_hex)
        stack_layout.currentIndex = 1
        postClaim()
    }

    function reset() {
        prepare_claim_rewards_result = default_prepare_claim_rewards_result
        send_result = ""
        text_error.text = ""
    }

    // Inside modal
    // width: stack_layout.children[stack_layout.currentIndex].width + horizontalPadding * 2
    width: 1200
    height: stack_layout.children[stack_layout.currentIndex].height + verticalPadding * 2
    StackLayout {
        width: parent.width
        id: stack_layout

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            ModalHeader {
                title: API.get().settings_pg.empty_string + (qsTr("Claim your %1 reward?", "TICKER").arg(API.get().current_coin_info.ticker))
            }

            DefaultText {
                visible: text_error.text === ""
                color: positive_claim_amount ? Style.colorText : Style.colorRed
                text_value: API.get().settings_pg.empty_string +
                            (positive_claim_amount ?
                                 qsTr("You will receive %1", "AMT TICKER").arg(General.formatCrypto("", prepare_claim_rewards_result.withdraw_answer.my_balance_change, API.get().current_coin_info.ticker))
                               : qsTr("Transaction fee is higher than the reward!"))
            }

            // List header
            Item {
                Layout.topMargin: 30
                Layout.fillWidth: true

                height: 40

                // Price
                DefaultText {
                    id: utxo_header
                    font.pixelSize: Style.textSizeSmall2

                    text_value: API.get().settings_pg.empty_string + (qsTr("UTXO"))

                    font.bold: true
                    horizontalAlignment: Text.AlignLeft

                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.03

                    anchors.verticalCenter: parent.verticalCenter
                }

                // Amount
                DefaultText {
                    id: amount_header

                    text_value: API.get().settings_pg.empty_string + (qsTr("Amount"))

                    font.pixelSize: utxo_header.font.pixelSize
                    font.bold: utxo_header.font.bold
                    horizontalAlignment: utxo_header.horizontalAlignment

                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.075

                    anchors.verticalCenter: parent.verticalCenter
                }

                // Reward
                DefaultText {
                    id: reward_header

                    text_value: API.get().settings_pg.empty_string + (qsTr("Reward"))

                    font.pixelSize: utxo_header.font.pixelSize
                    font.bold: utxo_header.font.bold
                    horizontalAlignment: Text.AlignLeft

                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.175

                    anchors.verticalCenter: parent.verticalCenter
                }

                // Accruing start
                DefaultText {
                    id: accruing_start_header

                    text_value: API.get().settings_pg.empty_string + (qsTr("Accruing Start At"))

                    font.pixelSize: utxo_header.font.pixelSize
                    font.bold: utxo_header.font.bold
                    horizontalAlignment: Text.AlignLeft

                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.300

                    anchors.verticalCenter: parent.verticalCenter
                }

                // Accruing Stop
                DefaultText {
                    id: accruing_stop_header

                    text_value: API.get().settings_pg.empty_string + (qsTr("Accruing Stop At"))

                    font.pixelSize: utxo_header.font.pixelSize
                    font.bold: utxo_header.font.bold
                    horizontalAlignment: Text.AlignLeft

                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.450

                    anchors.verticalCenter: parent.verticalCenter
                }

                // Time Left
                DefaultText {
                    id: time_left_header

                    text_value: API.get().settings_pg.empty_string + (qsTr("Time Left (d:hh:mm:ss)"))

                    font.pixelSize: utxo_header.font.pixelSize
                    font.bold: utxo_header.font.bold
                    horizontalAlignment: Text.AlignLeft

                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.600

                    anchors.verticalCenter: parent.verticalCenter
                }

                // Error
                DefaultText {
                    id: error_header

                    text_value: API.get().settings_pg.empty_string + (qsTr("Error"))

                    font.pixelSize: utxo_header.font.pixelSize
                    font.bold: utxo_header.font.bold
                    horizontalAlignment: Text.AlignLeft

                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.750

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
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 500
                clip: true

                model: prepare_claim_rewards_result.kmd_rewards_info.result

                delegate: Item {
                    width: root.width
                    height: utxo_value.font.pixelSize * 1.5

                    // UTXO
                    DefaultText {
                        id: utxo_value

                        anchors.left: parent.left
                        anchors.leftMargin: utxo_header.anchors.leftMargin

                        font.pixelSize: Style.textSizeSmall1

                        text_value: API.get().settings_pg.empty_string + ("#" + modelData.output_index)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Amount
                    DefaultText {
                        id: amount_value

                        anchors.left: parent.left
                        anchors.leftMargin: amount_header.anchors.leftMargin

                        font.pixelSize: utxo_value.font.pixelSize

                        text_value: API.get().settings_pg.empty_string + (modelData.amount)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Reward
                    DefaultText {
                        id: reward_value

                        anchors.left: parent.left
                        anchors.leftMargin: reward_header.anchors.leftMargin

                        font.pixelSize: utxo_value.font.pixelSize

                        text_value: API.get().settings_pg.empty_string + (modelData.accrued_rewards.Accrued || "-")
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Accruing Start
                    DefaultText {
                        id: accruing_start_value

                        anchors.left: parent.left
                        anchors.leftMargin: accruing_start_header.anchors.leftMargin

                        font.pixelSize: utxo_value.font.pixelSize

                        text_value: API.get().settings_pg.empty_string + (modelData.accrue_start_at_human_date)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Accruing Stop
                    DefaultText {
                        id: accruing_stop_value

                        anchors.left: parent.left
                        anchors.leftMargin: accruing_stop_header.anchors.leftMargin

                        font.pixelSize: utxo_value.font.pixelSize

                        text_value: API.get().settings_pg.empty_string + (modelData.accrue_stop_at_human_date)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Time Left
                    DefaultText {
                        id: time_left_value

                        anchors.left: parent.left
                        anchors.leftMargin: time_left_header.anchors.leftMargin

                        font.pixelSize: utxo_value.font.pixelSize

                        text_value: API.get().settings_pg.empty_string + (General.secondsToTimeLeft(Date.now()/1000, modelData.accrue_stop_at))
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
                            if(val === null || modelData.accrued_rewards.NotAccruedReason === undefined) return "-"

                            switch(modelData.accrued_rewards.NotAccruedReason) {
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

                            return API.get().settings_pg.empty_string + (val)
                        }

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Line
                    HorizontalLine {
                        visible: prepare_claim_rewards_result.kmd_rewards_info.result &&
                                 index !== prepare_claim_rewards_result.kmd_rewards_info.result.length - 1
                        width: parent.width
                        color: Style.colorWhite9
                        anchors.bottom: parent.bottom
                    }
                }
            }

            DefaultText {
                id: text_error
                color: Style.colorRed
                visible: text !== ''
            }

            // Buttons
            RowLayout {
                DefaultButton {
                    text: API.get().settings_pg.empty_string + (qsTr("Cancel"))
                    Layout.fillWidth: true
                    onClicked: root.close()
                }
                PrimaryButton {
                    text: API.get().settings_pg.empty_string + (qsTr("Confirm"))
                    Layout.fillWidth: true
                    onClicked: claimRewards()
                    enabled: positive_claim_amount
                }
            }
        }

        // Result Page
        SendResult {
            result: ({
                balance_change: prepare_claim_rewards_result.withdraw_answer.my_balance_change,
                fees: prepare_claim_rewards_result.withdraw_answer.fee_details.amount,
                date: prepare_claim_rewards_result.withdraw_answer.date
            })
            tx_hash: send_result

            function onClose() { root.close() }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
