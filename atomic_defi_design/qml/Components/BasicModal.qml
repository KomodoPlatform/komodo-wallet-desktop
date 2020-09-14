import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    padding: 10

    width: 900
    height: outer_layout.height + root.padding*2

    property alias title: modal_content.title
    default property alias content: modal_content.content
    property alias footer: modal_content.footer

    // Inside modal
    ColumnLayout {
        id: outer_layout
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        ModalContent {
            id: modal_content
        }
    }
}
