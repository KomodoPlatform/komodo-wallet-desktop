import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ColumnLayout {
    property alias title: title.text
    property alias text: text.text_value
    property alias value_color: text.color
    property alias privacy: text.privacy
    property bool expandable: false
    property bool expanded: false

    RowLayout {
        Layout.fillWidth: true

        Arrow {
            id: received_icon
            visible: expandable
            up: expanded
            color: expanded ? Style.colorRed : Style.colorGreen
            Layout.alignment: Qt.AlignVCenter
        }

        DefaultText {
            id: title
            Layout.fillWidth: true

            MouseArea {
                enabled: expandable
                anchors.fill: parent
                onClicked: {
                    expanded = !expanded
                }
            }
        }
    }

    DefaultText {
        visible: !expandable || expanded
        id: text
        Layout.fillWidth: true
        color: Style.modalValueColor
    }
}
