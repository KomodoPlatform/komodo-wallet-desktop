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
    readonly property var subPages: Main.getSubPages()
    readonly property date default_min_date: new Date("2019-01-01")
    readonly property date default_max_date: new Date(new Date().setDate(new Date().getDate() + 30))

    // Variable which holds the current sub-page of the SimpleView.
    property var currentSubPage: subPages.Trade
    onCurrentSubPageChanged: _selectedTabMarker.update()
    function applyDateFilter() {
        var min_date = default_min_date
        var max_date = default_max_date
        API.app.orders_mdl.orders_proxy_mdl.filter_minimum_date = default_min_date

        if(max_date.date < min_date.date)
            max_date.date = min_date.date

        API.app.orders_mdl.orders_proxy_mdl.filter_maximum_date = default_max_date
    }
    Component.onCompleted: {
     
        API.app.orders_mdl.orders_proxy_mdl.is_history = false
        applyDateFilter()
        API.app.orders_mdl.orders_proxy_mdl.apply_all_filtering()

        //list_model_proxy.set_coin_filter("ALL/ALL")

    }
    

    id: root
    function onRecoverFunds(order_id) {
        const result = API.app.recover_fund(order_id)
        console.log("Refund result: ", result)
        recover_funds_result = result
        recover_funds_modal.open()
    }

    Connections {
        target: exchange_trade
        function onOrderPlaced() {
            currentSubPage = subPages.Orders
        }
    }
    Column
    {
        width: 380
        y: 100
        spacing: 40
        anchors.verticalCenter: parent.verticalCenter
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

                border.width: 2
                border.color: 'transparent'
                height: parent.height-6
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
                    DexMouseArea
                    {
                        anchors.fill: parent
                        onClicked: if (currentSubPage !== subPages.History) currentSubPage = subPages.History
                        hoverEnabled: true
                    }
                }
            }
            
        }

        DexRectangle {
            height: simple_trade.height
            width: parent.width
            radius: 20
            color: theme.dexBoxBackgroundColor
            visible: root.currentSubPage===subPages.Trade
            sizeAnimationDuration: 250
            sizeAnimation: true
            Trade
            {
                id: simple_trade
                width: parent.width
                visible: parent.height>200
            }
        }
        
        DexRectangle {
            width: parent.width
            height: visible? 500 : 0
            radius: 20
            color: theme.dexBoxBackgroundColor
            visible: root.currentSubPage===subPages.Orders
            sizeAnimationDuration: 100
            sizeAnimation: true
            SubOrders {
                id: orders_view
            }
        }
        DexRectangle {
            width: parent.width
            height: visible? 500 : 0
            radius: 20
            color: theme.dexBoxBackgroundColor
            visible: root.currentSubPage===subPages.History
            sizeAnimationDuration: 100
            sizeAnimation: true
            SubHistory {
                id: history_view
            }
        }
    }
    ModalLoader {
        id: order_modal
        sourceComponent: Orders.OrderModal {}
    }
    ModalLoader {
        id: recover_funds_modal
        sourceComponent: LogModal {
            header: qsTr("Recover Funds Result")
            field.text: General.prettifyJSON(recover_funds_result)

            onClosed: recover_funds_result = "{}"
        }
    }

}