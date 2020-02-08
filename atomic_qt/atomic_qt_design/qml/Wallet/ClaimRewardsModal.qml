import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    id: root

    readonly property var default_prepare_claim_rewards_result: ({ has_error: false, error_message: "", tx_hex: "", date: "", balance_change: "", fees:"", explorer_url: ""})
    property var prepare_claim_rewards_result: default_prepare_claim_rewards_result
    property string send_result

    function canClaim() {
        return API.get().current_coin_info.is_claimable === true &&
                API.get().do_i_have_enough_funds(API.get().current_coin_info.ticker, API.get().current_coin_info.minimal_balance_for_asking_rewards) &&
                API.get().is_claiming_ready(API.get().current_coin_info.ticker)
    }

    function prepareClaimRewards() {
        if(canClaim()) {
            prepare_claim_rewards_result = API.get().claim_rewards(API.get().current_coin_info.ticker)
            console.log(JSON.stringify(prepare_claim_rewards_result))
        }
    }

    function claimRewards() {
        send_result = API.get().send(prepare_claim_rewards_result.tx_hex)
        console.log(JSON.stringify(API.get().claim_rewards(API.get().current_coin_info.ticker)))
    }

    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: 400
    // Inside modal
    ColumnLayout {
        width: parent.width

        ModalHeader {
            title: qsTr("Claim your ") + API.get().current_coin_info.ticker + qsTr(" reward?")
        }

        DefaultText {
            text: qsTr("You will receive ") + General.formatCrypto("", prepare_claim_rewards_result.balance_change, API.get().current_coin_info.ticker)
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: root.close()
            }
            Button {
                text: qsTr("Confirm")
                Layout.fillWidth: true
                onClicked: claimRewards()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
