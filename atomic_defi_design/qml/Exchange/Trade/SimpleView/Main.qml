//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! 3rdParty Imports
import Qaterial 1.0 as Qaterial

//! Project Imports
import "../../../Components"
import "../../../Constants"   //> Style
import "../Orders" as Orders
import "Main.js" as Main

ColumnLayout
{
    readonly property var subPages: Main.getSubPages()

    // Variable which holds the current sub-page of the SimpleView.
    property var currentSubPage: subPages.Trade
    onCurrentSubPageChanged: _selectedTabMarker.update()

    id: root
    anchors.centerIn: parent

    DefaultRectangle // Sub-pages Tabs Selector
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 200
        Layout.preferredHeight: 40
        Layout.bottomMargin: 25
        border.width: 4
        border.color: Style.colorWhite9
        color: Style.colorWhite6
        radius: 40

        DefaultRectangle // Selected Tab Rectangle
        {
            id: _selectedTabMarker

            function update() // Updates transform according to selected sub-page.
            {
                switch (currentSubPage)
                {
                case subPages.Trade:
                    anchors.right = undefined
                    anchors.horizontalCenter = undefined
                    anchors.left = parent.left
                    anchors.leftMargin = parent.border.width
                    break;
                case subPages.Orders:
                    anchors.left = undefined
                    anchors.right = undefined
                    anchors.horizontalCenter = parent.horizontalCenter
                    break;
                case subPages.History:
                    anchors.left = undefined
                    anchors.horizontalCenter = undefined
                    anchors.right = parent.right
                    anchors.rightMargin = parent.border.width
                    break;
                }
            }

            anchors.top: parent.top
            anchors.topMargin: parent.border.width

            height: parent.height - (parent.border.width * 2)
            width: (parent.width / 3) - (parent.border.width)
            radius: 40

            border.width: 0
            color: "#8b95ed"
        }

        DefaultText // Trade Tab
        {
            id: _tradeText
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Trade")
            font.pixelSize: Style.textSize
            MouseArea
            {
                anchors.fill: parent
                onClicked: if (currentSubPage !== subPages.Trade) currentSubPage = subPages.Trade
                hoverEnabled: true
            }
        }

        DefaultText // Orders Tab
        {
            id: _ordersText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Orders")
            font.pixelSize: Style.textSize
            MouseArea
            {
                anchors.fill: parent
                onClicked: if (currentSubPage !== subPages.Orders) currentSubPage = subPages.Orders
                hoverEnabled: true
            }
        }

        DefaultText // History Tab
        {
            id: _historyText
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("History")
            font.pixelSize: Style.textSize
            MouseArea
            {
                anchors.fill: parent
                onClicked: if (currentSubPage !== subPages.History) currentSubPage = subPages.History
                hoverEnabled: true
            }
        }
    }

    Trade
    {
        Layout.preferredWidth: width
        Layout.preferredHeight: height
        Layout.alignment: Qt.AlignHCenter
        visible: currentSubPage === subPages.Trade
    }
    Orders.OrdersPage
    {
        Layout.preferredWidth: width
        Layout.preferredHeight: height
        Layout.alignment: Qt.AlignHCenter
        visible: false//currentSubPage === subPages.Orders
    }
    Orders.OrdersPage
    {
        Layout.preferredWidth: width
        Layout.preferredHeight: height
        is_history: true
        visible: false//currentSubPage === subPages.History
    }
}
