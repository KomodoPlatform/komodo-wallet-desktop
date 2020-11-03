import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"

BasicModal {
    readonly property var claiming_faucet_rpc_result: api_wallet_page.claiming_faucet_rpc_data

    id: root
    width: 1200
    enabled: false

    ModalContent {
        id: status

        DefaultText {
            id: message
        }
    }

    function onClaimFaucetRpcResultChanged() {
        root.enabled = true
        root.visible = true
        status.title = qsTr(claiming_faucet_rpc_result.status)
        message.text_value = qsTr(claiming_faucet_rpc_result.message)
    }

    Component.onCompleted: {
        api_wallet_page.claimingFaucetRpcDataChanged.connect(onClaimFaucetRpcResultChanged)
    }
}
