import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Content
ColumnLayout {
    id: root

    property var details
    readonly property double total_time_passed: {
        if(!details) return 0
        const events = details.events
        if(events.length === 0) return 0

        return (events[events.length-1].timestamp - events[0].started_at*1000) / 1000
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
        model: details ? API.get().orders_mdl.get_expected_events_list(details.is_maker) : []

        delegate: Item {
            readonly property var event: {
                if(!details) return undefined
                const idx = details.events.map(e => e.state).indexOf(modelData)
                if(idx === -1) return undefined

                return details.events[idx]
            }

            readonly property double seconds_passed: {
                if(!event) return 0

                let start = event.started_at
                if(index === 0) start *= 1000
                return (event.timestamp - start)/1000
            }

            width: root.width
            height: 50

            DefaultText {
                id: icon

                text_value: event ? "●" : "○" // ◍ for unfinished one ●◍○
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                color: event ? Style.colorGreen : Style.colorTextDisabled // Orange for unfinished one
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
                    color: event ? Style.colorText : Style.colorTextDisabled
                }

                Rectangle {
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
                    visible: event
                    font.pixelSize: Style.textSizeSmall2

                    text_value: API.get().settings_pg.empty_string + (event ? qsTr("Took %1s", "SECONDS").arg(General.formatDouble(seconds_passed, 1)) : '')
                    color: Style.colorGreen

                    Layout.bottomMargin: 10
                }
            }
        }
    }
}
