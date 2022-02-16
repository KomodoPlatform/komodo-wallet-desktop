//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

//! Project Imports
import "../Constants"
import App 1.0

ColumnLayout
{
    id: root

    property alias         title:           _title
    property alias         titleText:       _title.text
    property var           titleAlignment:  Qt.AlignLeft
    property int           titleTopMargin:  20

    default property alias content:         _innerLayout.data

    Layout.fillWidth:       true
    Layout.leftMargin:      88
    Layout.rightMargin:     88
    Layout.topMargin:       52
    Layout.bottomMargin:    52

    DefaultText
    {
        id: _title
        Layout.topMargin: parent.titleTopMargin
        Layout.alignment: parent.titleAlignment
        font: DexTypo.head6
    }

    DefaultFlickable
    {
        flickableDirection: Flickable.VerticalFlick

        Layout.fillWidth: true
        Layout.preferredHeight: _innerLayout.height
        Layout.maximumHeight: window.height - 200

        ColumnLayout
        {
            id: _innerLayout
            anchors.centerIn: parent
        }
    }
}
