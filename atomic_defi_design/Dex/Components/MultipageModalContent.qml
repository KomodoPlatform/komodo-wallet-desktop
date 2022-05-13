import QtQuick 2.15
import QtQuick.Layouts 1.15

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

    Layout.fillWidth: true
    Layout.fillHeight: false
    Layout.maximumHeight: window.height - 50

    DefaultText
    {
        id: _title
        Layout.topMargin: root.titleTopMargin
        Layout.alignment: root.titleAlignment
        font: DexTypo.head6
    }

    DefaultFlickable
    {
        property int _maxHeight: window.height - 50 - _title.height - _footer.height - root.topMarginAfterTitle - root.spacing

        Layout.topMargin: root.topMarginAfterTitle
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        Layout.maximumHeight: _maxHeight
        contentHeight: _innerLayout.height

        flickableDirection: Flickable.VerticalFlick

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
    }
}
