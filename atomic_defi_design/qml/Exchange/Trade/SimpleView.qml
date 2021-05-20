import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"

ColumnLayout
{
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

                ComboBox
                {
                    id: from_coins_list
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    model: API.app.portfolio_pg.portfolio_mdl
                    currentIndex: 0
                    valueRole: "ticker"

                    delegate: ItemDelegate
                    {
                        width: from_coins_list.popup.width
                        contentItem: RowLayout
                        {
                            Layout.fillWidth: true
                            DefaultImage
                            {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                source: General.coinIcon(model.ticker)
                            }
                            DefaultText
                            {
                                font.pixelSize: Style.textSizeSmall5
                                text: model.ticker
                            }
                        }
                        highlighted: parent.highlightedIndex === index
                    }

                    contentItem: RowLayout
                    {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        DefaultImage
                        {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            source: General.coinIcon(parent.parent.currentValue)
                        }
                        DefaultText
                        {
                            text: parent.parent.currentValue
                        }
                    }

                    background: DefaultRectangle
                    {
                        border.width: 0
                        width: from_coins_list.width
                    }

                    popup: Popup
                    {
                        y: parent.height - 1
                        width: 180
                        height: 300

                        contentItem: ListView
                        {
                            clip: true
                            implicitHeight: contentHeight
                            model: from_coins_list.popup.visible ? from_coins_list.delegateModel : null
                            currentIndex: from_coins_list.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }
                        background: DefaultRectangle { radius: 2 }
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
}
