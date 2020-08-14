import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Content
ColumnLayout {
    id: root

    property var all_events: details ? API.get().orders_mdl.get_expected_events_list(details.is_maker) : []
    property var details
    readonly property double total_time_passed: {
        if(!details) return 0
        const events = details.events
        if(events.length === 0) return 0

        return (events[events.length-1].timestamp - events[0].started_at*1000) / 1000
    }

    readonly property int current_event_idx: {
        if(!details) return -1
        const events = details.events
        if(events.length === 0) return -1
        if(all_events.length === 0) return -1

        const idx = all_events.indexOf(events[events.length-1].state)
        if(idx === -1) return -1

        return idx + 1
    }

    // Title
    DefaultText {
        text_value: API.get().settings_pg.empty_string + (qsTr("Swap Progress") + "   |   " +
                                                           qsTr("%1 seconds", "SECONDS").arg(General.formatDouble(total_time_passed, 1)))
        font.pixelSize: Style.textSize1
    }

    Repeater {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: all_events

        delegate: Item {
            readonly property var event: {
                if(!details) return undefined
                const idx = details.events.map(e => e.state).indexOf(modelData)
                if(idx === -1) return undefined

                return details.events[idx]
            }

            readonly property double seconds_passed: {
                if(!event) return 0
                if(!event.started_at) return 0
                if(!event.timestamp) return 0

                let start = event.started_at
                if(index === 0) start *= 1000

                return (event.timestamp - start)/1000
            }

            readonly property bool is_current_event: index === current_event_idx

            width: root.width
            height: 50

            DefaultText {
                id: icon

                text_value: event || is_current_event ? "●" :  "○"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                color: event ? Style.colorGreen : is_current_event ? Style.colorOrange : Style.colorTextDisabled
            }

            ColumnLayout {
                id: col_layout

                anchors.left: icon.right
                anchors.leftMargin: icon.anchors.leftMargin
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                DefaultText {
                    id: name
                    font.pixelSize: Style.textSizeSmall4

                    text_value: API.get().settings_pg.empty_string + (modelData)
                    color: event || is_current_event ? Style.colorText : Style.colorTextDisabled
                }

                Rectangle {
                    id: bar
                    visible: event ? true : false
                    width: 300
                    height: 2

                    color: Style.colorWhite8

                    Rectangle {
                        width: parent.width * (total_time_passed > 0 ? (seconds_passed / total_time_passed) : 0)
                        height: parent.height
                        color: Style.colorGreen
                    }
                }

                DefaultText {
                    visible: bar.visible
                    font.pixelSize: Style.textSizeSmall2

                    text_value: API.get().settings_pg.empty_string + (event ? qsTr("Took %1s", "SECONDS").arg(General.formatDouble(seconds_passed, 1)) : '')
                    color: Style.colorGreen

                    Layout.bottomMargin: 10
                }
            }
        }
    }
}
