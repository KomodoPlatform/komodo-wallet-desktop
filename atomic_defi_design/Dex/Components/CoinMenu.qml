import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"
import App 1.0

Menu {
    Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
    Universal.accent: Style.colorQtThemeAccent
    Universal.foreground: Style.colorQtThemeForeground
    Universal.background: Style.colorQtThemeBackground
    property bool can_disable;

    // Ugly but required hack for automatic menu width, otherwise long texts are being cut
    width: {
        let result = 0
        let padding = 0

        for (let i = 0; i < count; ++i) {
            let item = itemAt(i)
            result = Math.max(item.contentItem.implicitWidth, result)
            padding = Math.max(item.padding, padding)
        }

        return result + padding * 2
    }

    MenuItem {
        id: disable_action
        text: qsTr("Disable %1", "TICKER").arg(ticker)
        onTriggered: API.app.disable_coins([ticker])
        enabled: can_disable
    }

    MenuItem {
        text: qsTr("Disable and Delete %1", "TICKER").arg(ticker)
        onTriggered: {
            const cloneTicker = General.clone(ticker)
            API.app.disable_coins([ticker])
            API.app.settings_pg.remove_custom_coin(cloneTicker)
            restart_modal.open()
        }
        enabled: disable_action.enabled && API.app.portfolio_pg.global_cfg_mdl.get_coin_info(ticker).is_custom_coin
    }

    MenuItem {
        enabled: !General.prevent_coin_disabling.running
        text: qsTr("Disable all %1 assets").arg(type)
        onTriggered: API.app.disable_coins(API.app.portfolio_pg.get_all_coins_by_type(type))
    }

    MenuItem {
        enabled: !General.prevent_coin_disabling.running
        text: qsTr("Disable all assets")
        onTriggered: API.app.disable_coins(API.app.portfolio_pg.get_all_enabled_coins())
    }

    MenuItem
    {
        enabled: !General.prevent_coin_disabling.running
        text: qsTr("Disable 0 balance assets")
        onTriggered: API.app.disable_no_balance_coins()
    }
}
