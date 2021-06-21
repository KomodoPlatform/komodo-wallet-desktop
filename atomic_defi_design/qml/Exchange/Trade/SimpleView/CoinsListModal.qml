//! Qt Imports
import QtQuick 2.15          //> Rectangle, MouseArea
import QtQuick.Layouts 1.15  //> RowLayout
import QtQuick.Controls 2.15 //> TextField, TextField.background, ItemDelegate

//! Project Imports
import "../../../Components" //> BasicModal, DefaultText
import "../../../Constants"  //> API

BasicModal
{
    property string selectedTicker
    id: root
    width: 450
    height: 560
    ColumnLayout {
        spacing: 10
        Layout.fillWidth: true
        height: 540
        DexLabel {
            text: qsTr("Select a ticker")
            font: _font.head5
            opacity: .7
        }
        HorizontalLine {

        }
        RowLayout
        {
            Layout.fillWidth: true
            TextField
            {
                id: searchName
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter
                placeholderText: "Search a name"
                font.pixelSize: Style.textSize1
                background: Rectangle
                {
                    color: theme.backgroundColor
                    border.width: 1
                    border.color: theme.colorRectangleBorderGradient1
                    radius: 10
                }
                onTextChanged:
                {
                    if (text.length > 30)
                        text = text.substring(0, 30)
                    API.app.trading_pg.market_pairs_mdl.left_selection_box.search_exp = text
                }

                Component.onDestruction: API.app.trading_pg.market_pairs_mdl.left_selection_box.search_exp = ""
            }
        }

        RowLayout
        {
            Layout.topMargin: 10
            Layout.fillWidth: true
            DefaultText { text: qsTr("Token name") }
        }

        DefaultListView
        {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: API.app.trading_pg.market_pairs_mdl.left_selection_box
            spacing: 20
            clip: true
            delegate: ItemDelegate
            {
                width: root.width
                anchors.horizontalCenter: root.horizontalCenter
                height: 40

                DefaultImage
                {
                    id: _coinIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5
                    anchors.left: parent.left
                    width: 30
                    height: 30
                    source: General.coinIcon(model.ticker)
                    DefaultText
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right
                        anchors.leftMargin: 20
                        text: General.formatCrypto("", model.balance, model.ticker)

                        DefaultText
                        {
                            anchors.left: parent.right
                            anchors.leftMargin: 5
                            text: "(%1)".arg(General.getFiatText(model.balance, model.ticker, false))
                        }
                    }
                }

                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        root.selectedTicker = model.ticker
                        close()
                    }
                }
            }
        }
    }
}
