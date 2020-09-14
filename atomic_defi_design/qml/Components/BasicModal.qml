import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    padding: 10

    width: 900
    height: Math.min(header.height + flickable.contentHeight + footer.height + root.padding*2 + outer_layout.spacing*2, window.height - 90)

    property alias title: header.title

    default property alias content: inner_layout.data
    property alias footer: footer.data

    // Inside modal
    ColumnLayout {
        id: outer_layout
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        ModalHeader {
            id: header
        }

        DefaultFlickable {
            id: flickable

            flickableDirection: Flickable.VerticalFlick

            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property int padding: 25
            contentWidth: inner_layout.width + flickable.padding
            contentHeight: inner_layout.height + flickable.padding

            ColumnLayout {
                id: inner_layout
                anchors.centerIn: parent
                spacing: Style.rowSpacing
                width: root.width - root.padding*2 - flickable.padding
                            - (flickable.scrollbar_visible ? 20 : 0) // Scrollbar margin
            }
        }

        // Buttons
        RowLayout {
            id: footer
            anchors.topMargin: Style.rowSpacing
            spacing: Style.buttonSpacing
        }
    }
}
