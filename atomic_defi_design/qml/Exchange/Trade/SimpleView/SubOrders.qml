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
    function update() {
        console.log('orders updated')
        main_order.list_model_proxy.is_history = false
        main_order.list_model_proxy.apply_all_filtering()
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
            id: main_order
            Layout.fillHeight: true
            Layout.fillWidth: true
            property bool is_history: false
            property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
            Component.onCompleted: {
                list_model_proxy.is_history = false
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
                text: order_list_view.count+" "+qsTr("Orders")
                anchors.horizontalCenter: parent.horizontalCenter
                y: -10
                //anchors.verticalCenterOffset: -4
            }
        }
        
    }
}