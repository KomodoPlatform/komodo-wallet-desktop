import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"

// Inside modal
ColumnLayout {
    id: modal_content

    Layout.fillWidth: true

    property alias title: header.title
    default property alias content: inner_layout.data
    property alias footer: footer.data

    ModalHeader {
        id: header
    }

    DefaultFlickable {
        id: flickable

        flickableDirection: Flickable.VerticalFlick

        Layout.preferredWidth: contentWidth
        Layout.preferredHeight: contentHeight
        Layout.maximumHeight: window.height - 200

        readonly property int padding: 25
        contentWidth: inner_layout.width + flickable.padding // Padding is for preventing shadows effect being cut
        contentHeight: inner_layout.height + flickable.padding

        ColumnLayout {
            id: inner_layout
            spacing: Style.rowSpacing
            anchors.centerIn: parent
            width: root.width - root.padding*2 - flickable.padding
        }
    }

    // Buttons
    RowLayout {
        id: footer
        anchors.topMargin: Style.rowSpacing
        spacing: Style.buttonSpacing
    }
}
