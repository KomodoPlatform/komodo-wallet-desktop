import QtQuick 2.15
import QtQuick.Layouts 1.15

DexRectangle
{
    id: root
    property alias source: icon.source
    property alias ticker: ticker.text
    property alias fullname: fullname.text
    property alias amount: amount.text

    Layout.preferredWidth: 226
    Layout.preferredHeight: 66
    radius: 10

    RowLayout
    {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 23

        DexImage
        {
            id: icon
            Layout.preferredWidth: 35
            Layout.preferredHeight: 35
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout
        {
            Layout.fillWidth: true
            RowLayout
            {
                Layout.fillWidth: true
                spacing: 5

                DexLabel
                {
                    id: ticker
                    Layout.fillWidth: true
                }

                DexLabel
                {
                    id: fullname
                    Layout.fillWidth: true
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                    font.pixelSize: 11
                }
            }

            DexLabel
            {
                id: amount
                Layout.fillWidth: true
                font.pixelSize: 11
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }

            DexLabel
            {
                id: amount_fiat
                Layout.fillWidth: true
                font.pixelSize: 11
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}