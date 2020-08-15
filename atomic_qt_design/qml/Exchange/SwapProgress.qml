import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Content
ColumnLayout {
    id: root

    property var details
    // QML Hack to get the events for .events field, because onDetailsChanged is not being triggered
    property var details_events: !details ? [] : details.events

    // MM2 data needs some modifications, see onDetails_eventsChanged
    property var corrected_events: ([])

    readonly property var all_events: !details ? [] : has_error_event ? corrected_events.map(e => e.state) : details.success_events

    onDetails_eventsChanged: {
        if(!details_events) return

        let events = General.clone(details_events)

        // Start timestamp of Started is in seconds somehow
        if(events.length > 0) events[0].started_at *= 1000

        // Set the missing started_at timestamps
        if(events.length >= 2) {
            for(let i = 1; i < events.length; ++i) {
                if(!events[i].started_at)
                    events[i].started_at = events[i - 1].timestamp
            }
        }

        corrected_events = events
    }

    readonly property bool has_error_event: {
        if(!details) return false

        const events = corrected_events

        for(let i = events.length - 1; i >= 0; --i)
            if(details.error_events.indexOf(events[i].state) !== -1)
                return true

        return false
    }

    readonly property double total_time_passed: {
        if(!details) return 0

        const events = corrected_events
        if(events.length === 0) return 0

        let sum = 0
        for(let i = 0; i < events.length; ++i) {
            const e = events[i]
            sum += e.timestamp - e.started_at
        }

        return sum
    }

    readonly property int current_event_idx: {
        if(!details) return -1
        const events = corrected_events
        if(events.length === 0) return -1
        if(all_events.length === 0) return -1

        const idx = all_events.indexOf(events[events.length-1].state)
        if(idx === -1) return -1

        return idx + 1
    }

    // Title
    DefaultText {
        text_value: API.get().settings_pg.empty_string + (qsTr("Progress details") + "     |     " + General.durationTextShort(total_time_passed))
        font.pixelSize: Style.textSize1
        Layout.bottomMargin: 10
    }

    Repeater {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: all_events

        delegate: Item {
            readonly property var event: {
                if(!details) return undefined
                const idx = corrected_events.map(e => e.state).indexOf(modelData)
                if(idx === -1) return undefined

                return corrected_events[idx]
            }

            readonly property double time_passed: {
                if(!event || !event.started_at || !event.timestamp) return 0

                return event.timestamp - event.started_at
            }

            readonly property bool is_current_event: index === current_event_idx

            width: root.width
            height: 50

            DefaultText {
                id: icon

                text_value: event || is_current_event ? "●" :  "○"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: col_layout.verticalCenter
                color: {
                    // Already exists, completed event
                    if(event) {
                        // Red for the Finished if swap failed
                        if(event.state === "Finished" && details.order_status === "failed") return Style.colorRed

                        // Red for error event, green for the others
                        return details.error_events.indexOf(event.state) === -1 ? Style.colorGreen : Style.colorRed
                    }

                    // In progress one is orange
                    if(is_current_event)
                        return Style.colorOrange

                    // Passive color for the rest
                    return Style.colorTextDisabled
                }
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

                    text_value: API.get().settings_pg.empty_string + (getEventText(modelData))
                    color: event ? Style.colorText : is_current_event ? Style.colorText2 : Style.colorTextDisabled
                }

                Rectangle {
                    id: bar
                    visible: event ? true : false
                    width: 300
                    height: 2

                    color: Style.colorWhite8

                    Rectangle {
                        width: parent.width * (total_time_passed > 0 ? (time_passed / total_time_passed) : 0)
                        height: parent.height
                        color: Style.colorGreen
                    }
                }

                DefaultText {
                    visible: bar.visible
                    font.pixelSize: Style.textSizeSmall2

                    text_value: API.get().settings_pg.empty_string + (event ? General.durationTextShort(time_passed) : '')
                    color: Style.colorGreen
                }
            }
        }
    }
}
