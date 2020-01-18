import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    id: window_layout

    transformOrigin: Item.Center
    spacing: 0

    SidebarLine {
        dashboard_index: General.idx_dashboard_wallet
        text: qsTr("Wallet")
        image: General.image_path + "menu-assets-white.svg"
        Layout.fillWidth: true
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_dex
        text: qsTr("DEX")
        image: General.image_path + "menu-exchange-white.svg"
        Layout.fillWidth: true
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_news
        text: qsTr("News")
        image: General.image_path + "menu-news-white.svg"
        Layout.fillWidth: true
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_dapps
        id: dapps_line
        text: qsTr("DApps")
        image: General.image_path + "menu-dapp-white.svg"
        Layout.fillWidth: true
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_settings
        text: qsTr("Settings")
        Layout.topMargin: dapps_line.height * 0.5
        image: General.image_path + "menu-settings-white.svg"
        Layout.fillWidth: true
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:150}
}
##^##*/
