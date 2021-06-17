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
    anchors.fill: parent
    readonly property date default_min_date: new Date("2019-01-01")
    readonly property date default_max_date: new Date(new Date().setDate(new Date().getDate() + 30))
    function update() {
        console.log('history updated')
        main_order.list_model_proxy.is_history = true
        main_order.list_model_proxy.apply_all_filtering()
    }
    function applyFilter() {

    }
    function applyDateFilter() {

    }
    DexModal {
        id: history_option
        height: 250
        width: 450
        x: ((dashboard.width/2)-(width/2))+30
        y: 100
        header: DexModalHeader {
            text: qsTr("History Options")
            color: 'transparent'
            
        }
        footer: Item {
            height: 60
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                spacing: 10
                DexAppButton {
                    height: 40
                    width: 120 
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Cancel")
                }
                DexAppButton {
                    height: 40
                    width: 130 
                    anchors.verticalCenter: parent.verticalCenter
                    backgroundColor: Qaterial.Colors.lightGreen700
                    text: qsTr("Apply filter")
                }
            }
        }
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            leftPadding: 15 
            rightPadding: 15
            RowLayout {
                width: parent.width - 20
                height: 60
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                DefaultSweetComboBox {
                    id: combo_base
                    model: API.app.portfolio_pg.global_cfg_mdl.all_proxy
                    onCurrentTickerChanged: applyFilter()
                    Layout.fillWidth: true
                    height: 100
                    valueRole: "ticker"
                    textRole: 'ticker'
                }
                Qaterial.ColorIcon {
                    Layout.alignment: Qt.AlignVCenter
                    source: Qaterial.Icons.swapHorizontal
                    DefaultMouseArea {
                        id: swap_button
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            const base_idx = combo_base.currentIndex
                            combo_base.currentIndex = combo_rel.currentIndex
                            combo_rel.currentIndex = base_idx
                        }
                    }
                }

                DefaultSweetComboBox {
                    id: combo_rel
                    model: API.app.portfolio_pg.global_cfg_mdl.all_proxy//combo_base.model
                    onCurrentTickerChanged: applyFilter()
                    Layout.fillWidth: true
                    height: 100
                    valueRole: "ticker"
                    textRole: 'ticker'

                }
                
            }
            spacing: 10
            RowLayout {
                width: parent.width - 20
                height: 60
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Qaterial.TextFieldDatePicker {
                    id: min_date
                    title: qsTr("From")
                    from: default_min_date
                    to: default_max_date
                    date: default_min_date
                    onAccepted: applyDateFilter()
                    Layout.fillWidth: true
                }

                Qaterial.TextFieldDatePicker {
                    id: max_date
                    enabled: min_date.enabled
                    title: qsTr("To")
                    from: min_date.date
                    to: default_max_date
                    date: default_max_date
                    onAccepted: applyDateFilter()
                    Layout.fillWidth: true
                }
            }
        }

        
    }
    ColumnLayout // Header
    {
        id: _swapCardHeader

        height: parent.height
        width: parent.width
        spacing: 20
        Item {
            width: parent.width
            Layout.preferredHeight: 60
            Qaterial.AppBarButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 10
                x: 320
                icon.source: Qaterial.Icons.filter
                onClicked: history_option.open()
            }
            Column {
                padding: 20
                spacing: 5
                DefaultText // Title
                {
                    text: qsTr("History")
                    font.pixelSize: Style.textSize1
                }

                DefaultText // Description
                {
                    anchors.topMargin: 12
                    font.pixelSize: Style.textSizeSmall4
                    text: qsTr("Display all history created")
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
            property bool is_history: true
            property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
            Component.onCompleted: {
                list_model_proxy.is_history = is_history
            }
            List {
                id: order_list_view
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
                text: order_list_view.count+" "+qsTr("Orders in history")
                anchors.horizontalCenter: parent.horizontalCenter
                y: -10
                //anchors.verticalCenterOffset: -4
            }
        }
        
    }
}