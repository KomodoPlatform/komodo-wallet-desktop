import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Content
ColumnLayout {
    id: root

    property var details

    readonly property var all_events: !details ? [] : has_error_event ? details.events.map(e => e.state) : details.success_events

    readonly property bool has_error_event: {
        if(!details) return false

        const events = details.events

        for(let i = events.length - 1; i >= 0; --i)
            if(details.error_events.indexOf(events[i].state) !== -1)
                return true

        return false
    }

    property double previous_total_time_passed: 0
    readonly property double total_time_passed: {
        if(!details) return 0

        const events = details.events

        let sum = 0
        for(let i = 0; i < events.length; ++i)
            sum += events[i].time_diff

        return sum
    }
    readonly property double total_time_passed_estimated: {
        const events = all_events

        let sum = 0
        for(let i = 0; i < events.length; ++i)
            sum += API.get().orders_mdl.average_events_time_registry[events[i]]

        return sum
    }

    readonly property int current_event_idx: {
        if(!details) return -1
        const events = details.events
        if(events.length === 0) return -1
        if(all_events.length === 0) return -1

        const last_state = events[events.length-1].state
        if(last_state === "Finished") return -1

        const idx = all_events.indexOf(last_state)
        if(idx === -1) return -1

        return idx + 1
    }

    property double simulated_time: 0
    Timer {
        running: current_event_idx !== -1
        interval: 1000
        repeat: true
        onTriggered: simulated_time += interval
    }

    function getTimeText(duration, estimated) {
        return `<font color="${Style.colorGreen}">` + qsTr("act", "SHORT FOR ACTUAL TIME") + ": " + `</font>` +
                `<font color="${Style.colorText}">` + General.durationTextShort(duration) + `</font>` +
                `<font color="${Style.colorTextDisabled}"> | ` + qsTr("est", "SHORT FOR ESTIMATED") + ": " +
                 General.durationTextShort(estimated) + `</font>`
    }

    property string last_uuid: ""
    onTotal_time_passedChanged: {
        // Reset for different order
        if(details.order_id !== last_uuid) {
            simulated_time = 0
            if(details) last_uuid = details.order_id
        }
        else {
            // Subtract the real time from the simulation, and continue
            simulated_time = Math.max(0, simulated_time - (total_time_passed - previous_total_time_passed))
        }

        previous_total_time_passed = total_time_passed
    }

    // Title
    DefaultText {
        text_value: API.get().settings_pg.empty_string + (
                        `<font color="${Style.colorText}">` + qsTr("Progress details") + `</font>` +
                        `<font color="${Style.colorTextDisabled}"> | </font>` +
                        getTimeText(total_time_passed + simulated_time, total_time_passed_estimated))
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
                const idx = details.events.map(e => e.state).indexOf(modelData)
                if(idx === -1) return undefined

                return details.events[idx]
            }

            readonly property bool is_current_event: index === current_event_idx

            readonly property bool is_active: General.exists(event) || is_current_event

            readonly property double time_passed: event ? event.time_diff : is_current_event ? simulated_time : 0

            width: root.width
            height: 50

            DefaultText {
                id: icon

                text_value: is_active ? "●" :  "○"
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
                    visible: is_active
                    width: 300
                    height: 2

                    color: Style.colorWhite8

                    Rectangle {
                        width: parent.width * (total_time_passed > 0 ? (time_passed / (total_time_passed + simulated_time)) : 0)
                        height: parent.height
                        color: Style.colorGreen
                    }
                }

                DefaultText {
                    visible: bar.visible
                    font.pixelSize: Style.textSizeSmall2

                    text_value: API.get().settings_pg.empty_string + (!is_active ? '' : getTimeText(time_passed, API.get().orders_mdl.average_events_time_registry[modelData]))
                }
            }
        }
    }
}
