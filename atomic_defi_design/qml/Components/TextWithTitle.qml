import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"

ColumnLayout {
    property alias title: title.text
    property alias text: text.text_value
    property alias value_color: text.color
    property alias privacy: text.privacy
    property bool expandable: false
    property bool expanded: false

    RowLayout {
        id: row_layout
        Layout.fillWidth: true

        Arrow {
            id: arrow_icon
            visible: expandable
            up: expanded
            color: mouse_area.containsMouse ? Style.colorOrange : expanded ? Style.colorRed : Style.colorGreen
            Layout.alignment: Qt.AlignVCenter
        }

        TitleText {
            id: title
            Layout.fillWidth: true

            color: Qt.lighter(Style.colorWhite4, mouse_area.containsMouse ? Style.hoverLightMultiplier : 1.0)

            DefaultMouseArea {
                id: mouse_area
                enabled: expandable
                anchors.fill: parent
                anchors.leftMargin: -arrow_icon.width - row_layout.spacing
                hoverEnabled: true
                onClicked: expanded = !expanded
            }
        }
    }

    DefaultTextEdit {
        clip: true
        id: text
        Layout.fillWidth: true
        color: Style.modalValueColor
        textFormat: TextEdit.AutoText

        readonly property bool show_content: !expandable || expanded

        Layout.preferredHeight: show_content ? contentHeight : 0
        Behavior on Layout.preferredHeight { SmoothedAnimation { id: expand_animation; duration: Style.animationDuration * 2; velocity: -1 } }

        opacity: show_content ? 1 : 0
        Behavior on opacity { SmoothedAnimation { duration: expand_animation.duration; velocity: -1 } }
    }
}
