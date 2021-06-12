//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! 3rdParty Imports
import Qaterial 1.0 as Qaterial

//! Project Imports
import "../../../Components"
import "../Orders" as Orders
import "Main.js" as Main

ColumnLayout
{
    readonly property var subPages: Main.getSubPages()

    // Variable which holds the current sub-page of the SimpleView.
    property var currentSubPage: subPages.Trade

    id: root
    anchors.centerIn: parent

    DefaultRectangle // Tabs Selector
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 200
    }

    Trade
    {
        Layout.alignment: Qt.AlignHCenter
        visible: currentSubPage === subPages.Trade
    }
    Orders.OrdersPage
    {
        Layout.alignment: Qt.AlignHCenter
        visible: currentSubPage === subPages.Orders
    }
    Orders.OrdersPage
    {
        is_history: true
        visible: currentSubPage === subPages.History
    }
}
