import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

ColumnLayout
{
    id: root

    property alias         title:               _title
    property alias         titleText:           _title.text
    property alias         subtitle:            _subtitle
    property alias         subtitleText:        _subtitle.text
    property var           titleAlignment:      Qt.AlignLeft
    property var           subtitleAlignment:   Qt.AlignLeft
    property int           titleTopMargin:      20
    property int           topMarginAfterTitle: 30
    
    property alias         flickable:           modal_flickable
    property int           flickMax:            500
    property alias         header:              _header.data
    default property alias content:             _innerLayout.data
    property alias         contentSpacing:      _innerLayout.spacing
    property alias         footer:              _footer.data

    Layout.fillWidth: true
    visible: true
    Layout.fillHeight: false
    Layout.maximumHeight: window.height - 50

    DexLabel
    {
        id: _title
        Layout.topMargin: root.titleTopMargin
        Layout.alignment: root.titleAlignment
        font: DexTypo.head6
        visible: text != ''
    }

    DexLabel
    {
        id: _subtitle
        Layout.topMargin: 5
        Layout.alignment: root.subtitleAlignment
        color: Dex.CurrentTheme.foregroundColor2
        font.pixelSize: 13
        visible: text != ''
    }

    // Header

    ColumnLayout
    {
        id: _header
        spacing: 10
        Layout.topMargin: root.topMarginAfterTitle
        Layout.preferredHeight: childrenRect.height
        visible: childrenRect.height > 0
    }

    DefaultFlickable
    {
        id: modal_flickable
        flickableDirection: Flickable.VerticalFlick

        Layout.topMargin: root.topMarginAfterTitle
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        Layout.maximumHeight: flickMax
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
        height: childrenRect.height
        visible: childrenRect.height > 0
    }
}
