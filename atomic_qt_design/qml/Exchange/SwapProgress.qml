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
        font.pixelSize: Style.textSize1
        font.bold: true
    }

    Repeater {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: details ? API.get().orders_mdl.get_expected_events_list(details.is_maker) : []

        delegate: ColumnLayout {
            property var event: {
                if(!details) return undefined
                const idx = details.events.map(e => e.state).indexOf(modelData)
                if(idx === -1) return undefined

                return details.events[idx]
            }

            width: root.width
            DefaultText {
                id: name
                font.pixelSize: Style.textSizeSmall4

                text_value: API.get().settings_pg.empty_string + (modelData)
                color: event ? Style.colorText : Style.colorTextDisabled
            }

            DefaultText {
                visible: event
                font.pixelSize: Style.textSizeSmall2

                text_value: API.get().settings_pg.empty_string + (event ? qsTr("Took %1s", "SECONDS").arg(General.formatDouble((event.timestamp - event.started_at)/1000, 1)) : '')
                color: Style.colorGreen

                Layout.bottomMargin: 10
            }
        }
    }
}
