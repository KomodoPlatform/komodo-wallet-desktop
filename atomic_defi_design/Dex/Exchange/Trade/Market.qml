import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import "../../Components"
import "../../Constants"

// OrderBook / Component import
import "OrderBook/" as OrderBook

// Best Order
import "BestOrder/" as BestOrder


ColumnLayout
{
    Layout.minimumWidth: 350
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignTop
    property alias currentIndex: marketTabView.currentIndex

    Qaterial.LatoTabBar
    {
        id: marketTabView
        property int orderbook: 0
        property int best_orders: 1

        background: null
        Layout.leftMargin: 6

        Qaterial.LatoTabButton
        {
            text: qsTr("Orderbook")
            font.pixelSize: 14
            textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
            textSecondaryColor: Dex.CurrentTheme.foregroundColor2
            indicatorColor: Dex.CurrentTheme.foregroundColor
        }
        Qaterial.LatoTabButton
        {
            text: qsTr("Best Orders")
            font.pixelSize: 14
            textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
            textSecondaryColor: Dex.CurrentTheme.foregroundColor2
            indicatorColor: Dex.CurrentTheme.foregroundColor
        }
    }

    Rectangle
    {
        Layout.fillHeight: true
        color: Dex.CurrentTheme.floatingBackgroundColor
        radius: 10
        Layout.preferredWidth: 350

        Qaterial.SwipeView
        {
            id: marketSwipeView
            clip: true
            interactive: false
            currentIndex: marketTabView.currentIndex
            anchors.fill: parent

            onCurrentIndexChanged:
            {
                marketSwipeView.currentItem.update();
            }
            
            OrderBook.Vertical
            {
                id: orderBook
            }

            // Best Orders
            BestOrder.List
            {
                id: bestOrders
            }
        }
    }
}
