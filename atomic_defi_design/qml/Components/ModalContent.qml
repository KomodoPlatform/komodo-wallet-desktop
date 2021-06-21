//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

//! Project Imports
import "../Constants"

// The content of a modal. Must be a child of a `BasicModal` component.
ColumnLayout
{
    Layout.fillWidth: true

    property alias         title: _header.title
    default property alias content: _innerLayout.data
    property alias         footer: _footer.data

    readonly property var  _parentModal: parent

    ModalHeader { id: _header }

    DefaultFlickable
    {
        readonly property int padding: 25

        flickableDirection: Flickable.VerticalFlick

        Layout.preferredWidth: _innerLayout.width + padding
        Layout.preferredHeight: _innerLayout.height + padding
        Layout.maximumHeight: window.height - 200

        ColumnLayout
        {
            id: _innerLayout
            spacing: Style.rowSpacing
            anchors.centerIn: parent
            width: root.width - (root.padding * 2) - 25
        }
    }

    RowLayout // Footer
    {
        id: _footer
        anchors.topMargin: Style.rowSpacing
        spacing: Style.buttonSpacing
    }
}
