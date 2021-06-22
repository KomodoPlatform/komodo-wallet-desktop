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

    ModalHeader { id: _header }

    DefaultFlickable
    {
        id: _flickable

       readonly property int padding: 25

        flickableDirection: Flickable.VerticalFlick

        Layout.preferredWidth: contentWidth
        Layout.preferredHeight: contentHeight
        Layout.maximumHeight: window.height - 200

        contentWidth: _innerLayout.width + padding      // Padding is for preventing shadows effect being cut
        contentHeight: _innerLayout.height + padding

        ColumnLayout
        {
            id: _innerLayout
            spacing: Style.rowSpacing
            anchors.centerIn: parent
            width: _modalWidth - (_modalPadding * 2) - _flickable.padding
        }
    }

    RowLayout // Footer
    {
        id: _footer
        anchors.topMargin: Style.rowSpacing
        spacing: Style.buttonSpacing
    }
}
