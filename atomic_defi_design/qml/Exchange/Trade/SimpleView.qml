import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"

ColumnLayout
{
    property string selectedTicker: "KMD"

    anchors.centerIn: parent

    DefaultRectangle
    {
        id: swap_card
        width: 370
        height: 360
        radius: 10

        ColumnLayout
        {
            id: swap_card_desc

            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 20

            RowLayout
            {
                DefaultText
                {
                    Layout.preferredWidth: swap_card.width - 70
                    id: title
                    text: qsTr("Swap")
                    font.pixelSize: Style.textSize1
                }

                // Settings wheel
                Image
                {
                    source: Qaterial.Icons.cog

                    DefaultColorOverlay
                    {
                        anchors.fill: parent
                        source: parent
                        color: "#ffffff"
                    }
                }
            }

            DefaultText // Description
            {
                Layout.topMargin: 6
                font.pixelSize: Style.textSizeSmall4
                text: qsTr("Instant trading with best orders")
            }

            HorizontalLine
            {
                Layout.topMargin: 12
                Layout.fillWidth: true
            }
        }

        ColumnLayout
        {
            anchors.top: swap_card_desc.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.horizontalCenter: parent.horizontalCenter

            // From
            DefaultRectangle
            {
                id: swap_from_card
                Layout.preferredWidth: swap_card.width - 20
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignHCenter

                DefaultText
                {
                    anchors.fill: parent
                    anchors.leftMargin: 25
                    anchors.topMargin: 10
                    text: qsTr("From")
                    font.pixelSize: Style.textSizeSmall5
                }

                TextField
                {
                    id: from_value
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    height: 30
                    placeholderText: "0.0"
                    font.pixelSize: Style.textSize1
                    background: Rectangle
                    {
                        color: theme.backgroundColor
                        //border.width: 1
                    }
                    onTextChanged: // Check that entered amount is lower or equal to your wallet
                    {

                    }
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                DefaultText
                {
                    color: from_value.color
                }

                Rectangle
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    width: 100
                    height: 40
                    radius: 20
                    border.width: 0
                    color: _mouseArea.containsMouse ? Style.colorSidebarHighlightGradient4 : theme.backgroundColor

                    DefaultMouseArea 
                    {
                        id: _mouseArea
                        anchors.fill: parent
                        onClicked: coinsListModalLoader.open()
                        hoverEnabled: true
                    }

                    DefaultImage
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        width: 20
                        height: 20
                        source: General.coinIcon(selectedTicker)
                        DefaultText
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right
                            anchors.leftMargin: 10
                            text: selectedTicker

                            Arrow 
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: 5
                                up: false
                            }
                        }
                    }

                    ModalLoader
                    {
                        id: coinsListModalLoader
                        sourceComponent: coinsListModal
                    }
                }
            }

            // To
            DefaultRectangle
            {
                Layout.preferredWidth: swap_card.width - 20
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 15

                DefaultText
                {
                    anchors.fill: parent
                    anchors.leftMargin: 25
                    anchors.topMargin: 10
                    text: qsTr("To")
                    font.pixelSize: Style.textSizeSmall5
                }

                DefaultText
                {
                    color: from_value.color
                    enabled: false
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    height: 30
                    text: "0.0"
                    font.pixelSize: Style.textSize1
                }
            }

            DefaultButton
            {
                Layout.topMargin: 10
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                enabled: !General.isZero(from_value.text)
                text: qsTr("Pick from best orders")
                //font.pixelSize: Style.textSizeSmall4
            }
        }
    }

    DefaultButton
    {
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: swap_card.width
        text: qsTr("Swap Now !")
    }

    // Coins list
    Component
    {
        id: coinsListModal
        BasicModal
        {
            property string searchNamePattern: ""

            id: root
            width: 450
            ModalContent
            {
                title: qsTr("Select a ticker")
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
                            root.searchNamePattern = text
                        }
                    }
                }

                RowLayout
                {
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    DefaultText { text: qsTr("Token name") }
                }

                ColumnLayout
                {
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    DefaultListView
                    {
                        Layout.fillWidth: true
                        model: API.app.trading_pg.market_pairs_mdl.left_selection_box
                        spacing: 20
                        delegate: ItemDelegate
                        {
                            width: root.width
                            anchors.horizontalCenter: root.horizontalCenter
                            height: 40

                            DefaultImage
                            {
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
                                    text: model.ticker
                                }
                            }

                            DefaultText // Balance
                            {

                            }

                            MouseArea 
                            {
                                anchors.fill: parent
                                onClicked: close()
                            }
                        }
                    }
                }
            }
        }
    }
}
