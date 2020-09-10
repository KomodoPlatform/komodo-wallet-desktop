import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    width: 900
    height: Math.min(header.height + inner_layout.height + footer.height + root.padding*2 + outer_layout.spacing*2, window.height - 90)

    readonly property alias title: header.title

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
            Layout.fillWidth: true
            Layout.fillHeight: true

            contentWidth: inner_layout.width
            contentHeight: inner_layout.height

            ColumnLayout {
                id: inner_layout
                width: root.width - root.padding*2 - 20 // Scrollbar margin
            }
        }

        // Buttons
        RowLayout {
            id: footer
        }
    }
}
