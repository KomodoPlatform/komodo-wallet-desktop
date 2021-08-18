//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

//! Project Imports
import "../Constants"
import App 1.0

// The content of a modal. Must be a child of a `BasicModal` component.
ColumnLayout
{
    Layout.fillWidth: true
    property alias         title: _header.title
    default property alias content: _innerLayout.data
    property alias         footer: _footer.data
    spacing: 10

    ModalHeader { 
        id: _header
        Layout.leftMargin: 30
    }

    DexFlickable
    {
        id: _flickable

       readonly property int padding: 25

        flickableDirection: Flickable.VerticalFlick

        rightMargin: -1

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
        Layout.topMargin: Style.rowSpacing
        Layout.rightMargin: 40
        Layout.leftMargin: 40
        spacing: Style.buttonSpacing
    }
}
