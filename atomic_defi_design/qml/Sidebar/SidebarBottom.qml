import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"
import "../Components"
import App 1.0

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

    Line
    {
        label.text: qsTr("Privacy")
        label.visible: sidebar.expanded

        DexSwitch
        {
            scale: 0.75
            anchors.verticalCenter: parent.verticalCenter

            checked: General.privacy_mode
            onCheckedChanged: General.privacy_mode = checked
        }
    }
}
