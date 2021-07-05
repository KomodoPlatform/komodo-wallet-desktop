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

Item
{
    id: _subOrdersRoot

    readonly property date default_min_date: new Date("2019-01-01")
    readonly property date default_max_date: new Date(new Date().setDate(new Date().getDate() + 30))
    property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
    property bool displayFilter: false

    anchors.fill: parent

    function update() {
        list_model_proxy.is_history = false
        applyTickerFilter()
        applyDateFilter()
        applyAllFiltering()
    }
    
    function applyTickerFilter() {  
        applyTickerFilter2(combo_base.currentTicker, combo_rel.currentTicker)
    }

    function applyTickerFilter2(ticker1, ticker2) {
        list_model_proxy.set_coin_filter(ticker1 + "/" + ticker2)
    }

    function applyDateFilter() {
        list_model_proxy.filter_minimum_date = min_date.date

        if(max_date.date < min_date.date)
            max_date.date = min_date.date

        list_model_proxy.filter_maximum_date = max_date.date
    }

    function applyFilter() {
        applyTickerFilter()
        applyDateFilter()
    }

    function applyAllFiltering() {
        list_model_proxy.apply_all_filtering()
    }

    ColumnLayout // Orders Content
    {
        height: parent.height
        width: parent.width
        spacing: 20

        Column // Header
        {
            leftPadding: 20
            topPadding: 20

            DefaultText // Title
            {
                text: qsTr("Orders")
                font.pixelSize: Style.textSize1
            }

            DexLabel // Description
            {
                width: _subOrdersRoot.width - 40
                anchors.topMargin: 12
                font.pixelSize: Style.textSizeSmall4
                //text: _filterApplied? "" : qsTr("Finished orders")
                DexLabel {
                    opacity: .4
                    text: qsTr("Filter") + ": %1 / %2 <br> %3: %4 - %5"
                                                    .arg(combo_base.currentTicker)
                                                    .arg(combo_rel.currentTicker)
                                                    .arg(qsTr("Date"))
                                                    .arg(min_date.date.toLocaleDateString(Locale.ShortFormat, "yyyy-MM-dd"))
                                                    .arg(max_date.date.toLocaleDateString(Locale.ShortFormat, "yyyy-MM-dd"))    
                }
                Qaterial.AppBarButton // Reset Form Button
                {
                    width: 50
                    height: 50
                    anchors.right: parent.right
                    anchors.rightMargin: -5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -8

                    icon.source: _subOrdersRoot.displayFilter ? Qaterial.Icons.close : Qaterial.Icons.filter

                    hoverEnabled: true

                    ToolTip.delay: 500
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: _subOrdersRoot.displayFilter ? qsTr("Close filtering options.") : qsTr("Open filering options.")

                    onClicked: _subOrdersRoot.displayFilter = !_subOrdersRoot.displayFilter
                }
            }
        }

        HorizontalLine
        {
            height: 2
            Layout.fillWidth: true
        }
        Item {
            id: main_order
            Layout.fillHeight: true
            Layout.fillWidth: true
            property bool is_history: false
            property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
            Component.onCompleted: {
                list_model_proxy.is_history = false
            }
            List { id: order_list_view }
            DexRectangle {
                anchors.fill: parent 
                color: theme.dexBoxBackgroundColor
                opacity: .8
                visible: _subOrdersRoot.displayFilter
                border.width: 0
            }
            DexRectangle {
                width: parent.width
                height: _subOrdersRoot.displayFilter? 330 : 60
                visible: height>100
                sizeAnimation: true
                color: theme.dexBoxBackgroundColor
                radius: 0
                y: -20
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    leftPadding: 15 
                    rightPadding: 15
                    visible: parent.height>250
                    DexLabel {
                        text: qsTr("Filter settings")
                        topPadding: 10
                        leftPadding: 10
                        font: _font.body1
                    }
                    RowLayout {
                        width: main_order.width - 30
                        height: 35
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0
                        DexLabel {
                            text: qsTr("Base Ticker")
                            leftPadding: 10
                            font: _font.body2
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            opacity: .6
                        }
                        DefaultSweetComboBox {
                            id: combo_base
                            model: API.app.portfolio_pg.global_cfg_mdl.all_proxy
                            onCurrentTickerChanged: applyTickerFilter()
                            height: 60
                            valueRole: "ticker"
                            textRole: 'ticker'
                        }
                        
                    }
                    RowLayout {
                        width: main_order.width - 30
                        height: 35
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        DexLabel {
                            text: qsTr("Rel Ticker")
                            leftPadding: 10
                            font: _font.body2
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            opacity: .6
                        }
                        DefaultSweetComboBox {
                            id: combo_rel
                            model: API.app.portfolio_pg.global_cfg_mdl.all_proxy//combo_base.model
                            onCurrentTickerChanged: applyTickerFilter()
                            height: 60
                            valueRole: "ticker"
                            textRole: 'ticker'

                        }
                        
                    }
                    spacing: 10
                    Qaterial.TextFieldDatePicker {
                        id: min_date
                        title: qsTr("From")
                        from: default_min_date
                        to: default_max_date
                        date: default_min_date
                        onAccepted: applyDateFilter()
                        width: parent.width - 50
                        height: 60
                        opacity: .8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Qaterial.TextFieldDatePicker {
                        id: max_date
                        enabled: min_date.enabled
                        title: qsTr("To")
                        from: min_date.date
                        to: default_max_date
                        date: default_max_date
                        onAccepted: applyDateFilter()
                        width: parent.width - 50
                        rightInset: 0
                        height: 60
                        opacity: .8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Item {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 60
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        spacing: 10
                        DexAppButton {
                            height: 35
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Cancel")
                            onClicked: {
                                _subOrdersRoot.displayFilter = false
                            }
                        }
                        DexAppButton {
                            height: 35
                            anchors.verticalCenter: parent.verticalCenter
                            backgroundColor: Qaterial.Colors.lightGreen700
                            text: qsTr("Apply filter")
                            onClicked: {
                                _subOrdersRoot.displayFilter = false
                                _subOrdersRoot.applyFilter()
                                _subOrdersRoot.applyAllFiltering()
                            }
                        }
                    }
                }
            }
            
        }
        HorizontalLine
        {
            height: 2
            Layout.fillWidth: true
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 15
            DexLabel // Title
            {
                text: order_list_view.count+" "+qsTr("Orders")
                anchors.horizontalCenter: parent.horizontalCenter
                y: -10
                //anchors.verticalCenterOffset: -4
            }
        }
        
    }
}
