import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ColumnLayout {
    id: window_layout

    transformOrigin: Item.Center
    spacing: 0

    SidebarLine {
        dashboard_index: General.idx_dashboard_settings
        text: API.get().empty_string + (qsTr("Settings"))
        image: General.image_path + "menu-settings-white.svg"
        Layout.fillWidth: true
        separator: false
    }

    SidebarLine {
        dashboard_index: General.idx_dashboard_light_ui
        text: API.get().empty_string + (qsTr("Light UI"))
        image: ""
        Layout.fillWidth: true
        separator: false
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:150}
}
##^##*/
