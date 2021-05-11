import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"

ColumnLayout {
    id: window_layout
    transformOrigin: Item.Center
    spacing: 0
    SidebarLine {
        dashboard_index: -1
        text_value: sidebar.expanded? qsTr("Settings") : ""
        image: General.image_path + "menu-settings-white.svg"
        Layout.fillWidth: true
        separator: false
        onCheckedChanged: setting_modal.open()
    }

    SidebarLine {
        dashboard_index: idx_dashboard_support
        text_value: sidebar.expanded? qsTr("Support") : ""
        image: General.image_path + "menu-support-white.png"
        Layout.fillWidth: true
        separator: false
    }

    SidebarLine {
        dashboard_index: idx_dashboard_privacy_mode
        text_value: sidebar.expanded? qsTr("Privacy") : ""
        image: ""
        Layout.fillWidth: true
        separator: false
        checked: General.privacy_mode
    }
}
