import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    id: root

    function canClaim() {
        return API.get().current_coin_info.is_claimable === true &&
                API.get().do_i_have_enough_funds(API.get().current_coin_info.ticker, API.get().current_coin_info.minimal_balance_for_asking_rewards) &&
                API.get().is_claiming_ready(API.get().current_coin_info.ticker)
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
            title: qsTr("Claim Rewards")
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
