import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"

ColumnLayout {
    id: window_layout

    transformOrigin: Item.Center
    spacing: 0

    SidebarLine {
        dashboard_index: General.idx_dashboard_portfolio
        text_value: qsTr("Dashboard")
        image: General.image_path + "menu-assets-portfolio.svg"
        Layout.fillWidth: true
        separator: false
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_wallet
        text_value: qsTr("Wallet")
        image: General.image_path + "menu-assets-white.svg"
        Layout.fillWidth: true
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_exchange
        text_value: qsTr("DEX")
        image: General.image_path + "menu-exchange-white.svg"
        Layout.fillWidth: true
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_news
        text_value: qsTr("News")
        image: General.image_path + "menu-news-white.svg"
        Layout.fillWidth: true
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_dapps
        text_value: qsTr("Dapps")
        image: General.image_path + "menu-dapp-white.svg"
        Layout.fillWidth: true
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:150}
}
##^##*/
