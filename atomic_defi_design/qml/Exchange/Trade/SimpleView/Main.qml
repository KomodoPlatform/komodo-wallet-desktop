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

Item {
    id: root

    readonly property var subPages: Main.getSubPages()

    // Variable which holds the current sub-page of the SimpleView.
    property var currentSubPage: subPages.Trade

    onCurrentSubPageChanged: _selectedTabMarker.update()

    Connections
    {
        target: exchange_trade
        function onOrderPlaced()
        {
            currentSubPage = subPages.Orders
        }
    }

    Column
    {
        width: root.currentSubPage===subPages.Trade? _simpleTrade.best? 600 : 380 : 380
        y: 120
        spacing: 30
        anchors.horizontalCenter: parent.horizontalCenter

        InnerBackground // Sub-pages Tabs Selector
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 250
            height: 40
            border.width: 1
            border.color: theme.dexBoxBackgroundColor
            color: theme.surfaceColor
            radius: 40

            FloatingBackground // Selected Tab Rectangle
            {
                id: _selectedTabMarker

                function update() // Updates transform according to selected sub-page.
                {
                    switch (currentSubPage)
                    {
                    case subPages.Trade:
                        x = 0
                        break;
                    case subPages.Orders:
                        x = (parent.width / 3) 
                        orders_view.update()
                        break;
                    case subPages.History:
                        x = (parent.width / 3) *2
                        history_view.update()
                        break;
                    }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 150
                    }
                }
                show_shadow: false
                light_gradient.visible: false

                border.width: 2
                border.color: 'transparent'
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                width: (parent.width / 3) 
                radius: 40
                color: theme.accentColor
            }
            RowLayout {
                anchors.fill: parent
                spacing: 0
                DexLabel // Trade Tab
                {
                    id: _tradeText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.preferredWidth: parent.width/3
                    Layout.fillHeight: true
                    text: qsTr("Trade")
                    font.pixelSize: Style.textSize
                    color: children[1].containsMouse? currentSubPage === subPages.Trade? theme.foregroundColor : theme.accentColor : theme.foregroundColor
                    DexMouseArea
                    {
                        anchors.fill: parent
                        onClicked: if (currentSubPage !== subPages.Trade) currentSubPage = subPages.Trade
                        hoverEnabled: true
                    }
                }

                DexLabel // Orders Tab
                {
                    id: _ordersText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.preferredWidth: parent.width/3
                    Layout.fillHeight: true
                    text: qsTr("Orders")
                    font.pixelSize: Style.textSize
                    color: children[1].containsMouse? currentSubPage === subPages.Orders? theme.foregroundColor : theme.accentColor : theme.foregroundColor
                    DexMouseArea
                    {
                        anchors.fill: parent
                        onClicked: if (currentSubPage !== subPages.Orders) currentSubPage = subPages.Orders
                        hoverEnabled: true
                    }
                }

                DexLabel // History Tab
                {
                    id: _historyText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.preferredWidth: parent.width/3
                    Layout.fillHeight: true
                    text: qsTr("History")
                    font.pixelSize: Style.textSize
                    color: children[1].containsMouse? currentSubPage === subPages.History? theme.foregroundColor : theme.accentColor : theme.foregroundColor
                    DexMouseArea
                    {
                        anchors.fill: parent
                        onClicked: if (currentSubPage !== subPages.History) currentSubPage = subPages.History
                        hoverEnabled: true
                    }
                }
            }
            
        }

        SwipeView {
            id: _swipeSimplifiedView
            currentIndex: root.currentSubPage
            anchors.horizontalCenter: parent.horizontalCenter
            width: 600
            height: 650
            clip: true
            interactive: false
            Item {
                DexRectangle {
                    id: subTradePage
                    height: _simpleTrade.height
                    width: _simpleTrade.best? 600 : _simpleTrade.coinSelection? 450 : 380
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 20
                    color: theme.dexBoxBackgroundColor
                    sizeAnimationDuration: 250
                    sizeAnimation: true
                    ClipRRect {
                        anchors.fill: parent
                        radius: 20 
                        Trade
                        {
                            id: _simpleTrade
                            width: parent.width
                        }
                    }
                }
            }
            Item {
                DexRectangle {
                    width: 380
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 500 
                    radius: 20
                    color: theme.dexBoxBackgroundColor
                    SubOrders {
                        id: orders_view
                    }
                }
            }
            Item {
                DexRectangle {
                    width: 380
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 500 
                    radius: 20
                    color: theme.dexBoxBackgroundColor
                    SubHistory {
                        id: history_view
                    }
                }
            }
        }
    }
    ModalLoader {
        id: order_modal
        sourceComponent: Orders.OrderModal {}
    }
}
