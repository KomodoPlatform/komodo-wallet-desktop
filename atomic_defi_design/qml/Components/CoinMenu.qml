import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12
import "../Constants"

Menu {
    Action {
        id: disable_action
        text: API.app.settings_pg.empty_string + (qsTr("Disable %1", "TICKER").arg(ticker))
        onTriggered: API.app.disable_coins([ticker])
        enabled: General.canDisable(ticker)
    }

    Action {
        text: API.app.settings_pg.empty_string + (qsTr("Disable and Delete %1", "TICKER").arg(ticker))
        onTriggered: {
            API.app.disable_coins([ticker])
            API.app.settings_pg.remove_custom_coin(ticker)
        }
        enabled: disable_action.enabled && API.app.get_coin_info(ticker).is_custom_coin
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

