import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"

DefaultRectangle
{
    id: swap_card
    width: 370
    height: 320
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
            }

            ComboBox
            {
                id: from_coins_list
                model: API.app.portfolio_pg.portfolio_mdl
                currentIndex: 0
                delegate: ItemDelegate
                {
                    contentItem: DefaultText
                    {
                        width: 100
                        text: model.ticker
                    }
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 15
                background: DefaultRectangle
                {
                    anchors.right: parent.right
                    width: 100
                    Image
                    {
                        anchors.left: parent.left
                        source: General.coinIcon(from_coins_list.currentValue)
                    }
                    DefaultText
                    {
                        text: from_coins_list.currentValue
                    }
                }
                popup: Popup
                {
                    y: from_coins_list.height - 1
                    width: 100
                    height: contentItem.implicitHeight
                    contentItem: ListView
                    {
                        implicitHeight: contentHeight
                        model: from_coins_list.popup.visible ? from_coins_list.delegateModel : null
                    }
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

            TextField
            {
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
            }
        }
    }
}
