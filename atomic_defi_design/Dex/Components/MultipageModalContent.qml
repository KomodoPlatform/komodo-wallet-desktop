//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

//! Project Imports
import "../Constants"
import App 1.0

ColumnLayout
{
    id: root

    property alias         title:               _title
    property alias         titleText:           _title.text
    property var           titleAlignment:      Qt.AlignLeft
    property int           titleTopMargin:      20
    property int           topMarginAfterTitle: 30

    default property alias content:         _innerLayout.data
    property alias         footer:          _footer.data
    property alias         header:          _header.data
    property var scrollable_height: window.height - _title.height - _header.height - _footer.height - titleTopMargin * 2 - topMarginAfterTitle - 180

    Layout.fillWidth: true
    Layout.maximumHeight: window.height - 50

    DexLabel
    {
        id: _title
        Layout.topMargin: root.titleTopMargin
        Layout.alignment: root.titleAlignment
        font: DexTypo.head6
        visible: text != ''
    }

    // Header
    ColumnLayout
    {
        id: _header
        Layout.topMargin: root.titleTopMargin
        visible: childrenRect.height > 0
    }


    DexFlickable
    {
        flickableDirection: Flickable.VerticalFlick

        Layout.topMargin: root.topMarginAfterTitle
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        Layout.maximumHeight: scrollable_height

        contentHeight: _innerLayout.height

        ColumnLayout
        {
            id: _innerLayout
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            width: parent.width
        }
    }

    // Footer
    RowLayout
    {
        id: _footer
        Layout.topMargin: Style.rowSpacing
        spacing: Style.buttonSpacing
        visible: childrenRect.height > 0
    }
}
