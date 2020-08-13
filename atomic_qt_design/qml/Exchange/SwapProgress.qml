import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Content
ColumnLayout {
    id: root

    property var details

    // Title
    DefaultText {
        text_value: API.get().settings_pg.empty_string + (qsTr("Swap Progress"))
    }

    DefaultListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: details ? API.get().orders_mdl.get_expected_events_list(details.is_maker) : []

        delegate: ColumnLayout {
            width: root.width
            DefaultText {
                id: name
                font.pixelSize: Style.textSizeSmall4

                text_value: API.get().settings_pg.empty_string + (modelData)
                color: Style.colorWhite4
            }
        }
    }
}
