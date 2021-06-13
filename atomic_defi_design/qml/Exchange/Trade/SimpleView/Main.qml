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

    // Variable which holds the current sub-page of the SimpleView.
    property var currentSubPage: subPages.Trade
    onCurrentSubPageChanged: _selectedTabMarker.update()

    id: root
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
                        break;
                    case subPages.History:
                        x = (parent.width / 3) *2
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
            /*Orders.OrdersPage
            {
                anchors.fill: parent
                visible: parent.height>200
            }*/
            Item {
                anchors.fill: parent
                ColumnLayout // Header
                {
                    id: _swapCardHeader

                    height: parent.height
                    width: parent.width
                    spacing: 20
                    Item {
                        width: parent.width
                        Layout.preferredHeight: 60
                        Column {
                            padding: 20
                            spacing: 5
                            DefaultText // Title
                            {
                                text: qsTr("Orders")
                                font.pixelSize: Style.textSize1
                            }

                            DefaultText // Description
                            {
                                anchors.topMargin: 12
                                font.pixelSize: Style.textSizeSmall4
                                text: qsTr("Display all orders created")
                            }
                        }
                    }
                    HorizontalLine
                    {
                        height: 2
                        Layout.fillWidth: true
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
                        Component.onCompleted: {
                            list_model_proxy.is_history = true
                        }
                        DexListView {
                            id: order_list_view
                            anchors.fill: parent
                            model: API.app.orders_mdl
                            delegate: ClipRRect {
                                property var details: model
                                readonly property bool is_placed_order: !details ? false :
                                                       details.order_id !== ''

                                property bool expanded: false
                                width: order_list_view.width
                                height: expanded? colum_order.height+10 : 35
                                radius: 1
                                Rectangle {
                                    anchors.fill: parent
                                    color: order_mouse_area.containsMouse? theme.surfaceColor : 'transparent'
                                    border.color: theme.surfaceColor
                                    border.width: expanded? 1 : 0
                                }
                                Column {
                                    id: colum_order
                                    width: parent.width
                                    spacing: 5
                                    RowLayout {
                                        width: parent.width
                                        height: 30
                                        spacing: 5
                                        Item {
                                            Layout.preferredWidth: 25 
                                            height: 30
                                            BusyIndicator {
                                                width: 20
                                                height: width
                                                anchors.centerIn: parent
                                                running: true
                                            }
                                        }
                                        DefaultImage {
                                            id: base_icon
                                            source: General.coinIcon(!details ? atomic_app_primary_coin :
                                                                                details.base_coin?? atomic_app_primary_coin)
                                            Layout.preferredWidth: Style.textSize1
                                            Layout.preferredHeight: Style.textSize1
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                        DefaultText {
                                            id: base_amount
                                            text_value: !details ? "" :
                                                        General.formatCrypto("", details.base_amount, details.base_coin)
                                            //details.base_amount_current_currency, API.app.settings_pg.current_currency
                                            font.pixelSize: 11


                                            Layout.fillHeight: true
                                            Layout.preferredWidth: 110
                                            verticalAlignment: Label.AlignVCenter
                                            privacy: is_placed_order
                                        }
                                        Item {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SwapIcon {
                                                //visible: !status_text.visible
                                                width: 30
                                                height: 30
                                                opacity: .6
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                top_arrow_ticker: !details ? atomic_app_primary_coin :
                                                                             details.base_coin?? ""
                                                bottom_arrow_ticker: !details ? atomic_app_primary_coin :
                                                                                details.rel_coin?? ""
                                            }
                                        }

                                        DefaultText {
                                            id: rel_amount
                                            text_value: !details ? "" :
                                                        General.formatCrypto("", details.rel_amount, details.rel_coin)
                                            font.pixelSize: base_amount.font.pixelSize

                                            Layout.fillHeight: true
                                            Layout.preferredWidth: 110
                                            verticalAlignment: Label.AlignVCenter
                                            horizontalAlignment: Label.AlignRight
                                            privacy: is_placed_order
                                        }
                                        DefaultImage {
                                            id: rel_icon
                                            source: General.coinIcon(!details ? atomic_app_primary_coin :
                                                                                details.rel_coin?? atomic_app_secondary_coin)

                                            width: base_icon.width
                                            Layout.preferredWidth: Style.textSize1
                                            Layout.preferredHeight: Style.textSize1
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                        Item {
                                            Layout.fillWidth: true 
                                            Layout.fillHeight: true
                                            opacity: .6
                                            Qaterial.ColorIcon {
                                                anchors.centerIn: parent
                                                source:  expanded? Qaterial.Icons.chevronUp : Qaterial.Icons.chevronDown
                                                iconSize: 14
                                            }
                                        }

                                    }
                                    RowLayout {
                                        width: parent.width-40
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        height: 20
                                        opacity: .6
                                        DexLabel {
                                            Layout.fillWidth: true 
                                            Layout.fillHeight: true 
                                            verticalAlignment: Label.AlignVCenter
                                            text: "KMD 2445555.55555"
                                        }
                                        DexLabel {
                                            Layout.fillWidth: true 
                                            Layout.fillHeight: true 
                                            verticalAlignment: Label.AlignVCenter
                                            horizontalAlignment: Text.AlignRight
                                            text: "RICK 2445555.02345"
                                        }
                                    }
                                }
                                DexMouseArea {
                                    id: order_mouse_area
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        expanded = !expanded
                                        if(expanded){
                                            order_list_view.currentIndex = index
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
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
            Orders.OrdersPage
            {
                anchors.fill: parent
                is_history: true
                visible: parent.height>200
            }
        }

        
        
    }

}