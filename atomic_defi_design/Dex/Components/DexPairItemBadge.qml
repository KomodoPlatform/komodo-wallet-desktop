import QtQuick 2.15
import QtQuick.Layouts 1.15

DexRectangle
{
    id: root
    property alias source: icon.source
    property alias ticker: ticker.text
    property alias fullname: fullname.text
    property alias amount: amount.text

    Layout.preferredWidth: 260
    Layout.preferredHeight: 66
    radius: 10

    RowLayout
    {
        Layout.fillWidth: true
        Layout.fillHeight: true
        anchors.fill: parent
        anchors.margins: 15
        spacing: 8

        Item { Layout.fillWidth: true }

        DexImage
        {
            id: icon
            Layout.preferredWidth: 35
            Layout.preferredHeight: 35
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        ColumnLayout
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 5

            DexLabel
            {
                id: ticker
                Layout.fillWidth: true
                font.pixelSize: 11
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.NoWrap
            }

            DexLabel
            {
                id: amount
                Layout.fillWidth: true
                font.pixelSize: 11
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.NoWrap
            }
        }

        Item { Layout.fillWidth: true }

        ColumnLayout
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 5

            DexLabel
            {
                id: fullname
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: 11
            }

            DexLabel
            {
                id: amount_fiat
                visible: text != ''
                Layout.fillWidth: true
                font.pixelSize: 11
                wrapMode: Text.NoWrap
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
            }
        }
        
        Item { Layout.fillWidth: true }
    }
}