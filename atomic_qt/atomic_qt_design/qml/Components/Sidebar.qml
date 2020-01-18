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
        text: "Wallet"
        image: General.image_path + "menu-assets-white.svg"
    }

    SidebarLine {
        text: "DEX"
        image: General.image_path + "menu-exchange-white.svg"
    }

    SidebarLine {
        text: "News"
        image: General.image_path + "menu-news-white.svg"
    }

    SidebarLine {
        id: dapps_line
        text: "DApps"
        image: General.image_path + "menu-dapp.svg"
    }

    SidebarLine {
        text: "Settings"
        Layout.topMargin: dapps_line.height * 0.5
        image: General.image_path + "menu-settings-white.svg"
    }
}







/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
