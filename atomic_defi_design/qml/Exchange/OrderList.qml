import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import ".."

InnerBackground {
    property string title
    property var items
    property alias empty_text: no_orders.text_value
    property bool is_history: false

    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        width: parent.width
        height: parent.height

        DefaultText {
            text_value: title + " (" + items.length + ")"

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 10

            font.pixelSize: Style.textSize2
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        // No orders
        DefaultText {
            id: no_orders
            wrapMode: Text.Wrap
            visible: items.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            color: Style.colorWhite5

            text_value: qsTr("You don't have any orders.")
        }

        // List
        DefaultListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: items.orders_proxy_mdl
            enabled: !is_history || !API.app.orders_mdl.fetching_busy

            property int animationTimestamp: 0
            readonly property int animationTime: 600
            readonly property int animationDelay: 50
            property bool resetAnimation: false

            // Row
            delegate: OrderLine {
                readonly property double anim_time: list.animationTimestamp > index*list.animationDelay ?
                                                Math.min((list.animationTimestamp-index*list.animationDelay)/(list.animationTime), 1) : 0
                details: model
                opacity: anim_time
            }

            populate:  Transition {
                PropertyAction { target: list; property: "resetAnimation"; value: !list.resetAnimation }
            }


            onResetAnimationChanged: {
                list.animationTimestamp = 0
                spawn_anim_timer.repeat = true
                spawn_anim_timer.restart()
            }

            Timer {
                id: spawn_anim_timer
                interval: General.delta_time
                running: true
                repeat: true
                onTriggered: () => {
                     list.animationTimestamp += interval
                     if(list.animationTimestamp > list.animationDelay*list.count + list.animationTime)
                         repeat = false
                }
            }
        }

        // Pagination
        Pagination {
            visible: is_history
            enabled: list.enabled
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.bottomMargin: Layout.topMargin
        }
    }
}
