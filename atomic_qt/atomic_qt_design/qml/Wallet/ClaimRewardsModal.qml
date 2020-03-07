import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

DefaultModal {
    id: root

    readonly property var default_prepare_claim_rewards_result: ({ has_error: false, error_message: "", tx_hex: "", date: "", balance_change: "", fees:"", explorer_url: ""})
    property var prepare_claim_rewards_result: default_prepare_claim_rewards_result
    property string send_result

    // Override
    function postClaim() {}

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
        if(prepare_claim_rewards_result.has_error) {
            text_error.text = prepare_claim_rewards_result.error_message
        }
        else {
            text_error.text = ""
        }
    }

    function claimRewards() {
        send_result = API.get().send_rewards(prepare_claim_rewards_result.tx_hex)
        console.log(JSON.stringify(API.get().claim_rewards(API.get().current_coin_info.ticker)))
        stack_layout.currentIndex = 1
        postClaim()
    }

    function reset() {
        prepare_claim_rewards_result = default_prepare_claim_rewards_result
        send_result = ""
        text_error.text = ""
    }

    // Inside modal
    width: stack_layout.children[stack_layout.currentIndex].width + horizontalPadding * 2
    height: stack_layout.children[stack_layout.currentIndex].height + verticalPadding * 2
    StackLayout {
        id: stack_layout

        ColumnLayout {
            Layout.fillWidth: true

            ModalHeader {
                title: qsTr("Claim your ") + API.get().current_coin_info.ticker + qsTr(" reward?")
            }

            DefaultText {
                visible: text_error.text === ""
                text: qsTr("You will receive ") + General.formatCrypto("", prepare_claim_rewards_result.balance_change, API.get().current_coin_info.ticker)
            }

            DefaultText {
                id: text_error
                color: Style.colorRed
                visible: text !== ''
            }

            // Buttons
            RowLayout {
                DefaultButton {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    onClicked: root.close()
                }
                PrimaryButton {
                    text: qsTr("Confirm")
                    Layout.fillWidth: true
                    onClicked: claimRewards()
                }
            }
        }

        // Result Page
        SendResult {
            result: prepare_claim_rewards_result
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
