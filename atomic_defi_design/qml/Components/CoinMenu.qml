import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"

Menu {
    Action {
        id: disable_action
        text: qsTr("Disable %1", "TICKER").arg(ticker)
        onTriggered: API.app.disable_coins([ticker])
        enabled: General.canDisable(ticker)
    }

    Action {
        text: qsTr("Disable and Delete %1", "TICKER").arg(ticker)
        onTriggered: {
            const cloneTicker = General.clone(ticker)
            API.app.disable_coins([ticker])
            API.app.settings_pg.remove_custom_coin(cloneTicker)
            restart_modal.open()
        }
        enabled: disable_action.enabled && API.app.get_coin_info(ticker).is_custom_coin
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

