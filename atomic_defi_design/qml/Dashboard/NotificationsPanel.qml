import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt.labs.platform 1.0

import "../Constants"
import "../Components"

FloatingBackground {
    id: root

    property var notifications_list: ([])

    function reset() {
        visible = false
        notifications_list = []
    }

    function showApp() {
        switch(window.true_visibility) {
            case 4:
                window.showMaximized()
                break
            case 5:
                window.showFullScreen()
                break
            default:
                window.show()
                break
        }

        window.raise()
        window.requestActivate()
    }

    visible: false

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        hoverEnabled: true
    }

    function performLastNotificationAction() {
        if(notifications_list.length === 0) return

        const notification = notifications_list[0]

        switch(notification.click_action) {
        case "open_notifications":
            root.visible = true
            break
        case "open_wallet_page":
            api_wallet_page.ticker = notification.params.ticker
            dashboard.current_page = General.idx_dashboard_wallet
            break
        case "open_swaps_page":
            dashboard.current_page = General.idx_dashboard_exchange
            exchange.current_page = exchange.isSwapDone(notification.params.new_swap_status) ? General.idx_exchange_history : General.idx_exchange_orders
            break
        default:
            console.log("Unknown notification click action", notification.click_action)
            break
        }
    }

    function newNotification(params, id, title, message, time, click_action = "open_notifications") {
        const obj = { params, id, title, message, time, click_action }

        // Update if it already exists
        let updated_existing_one = false
        for(let i = 0; i < notifications_list.length; ++i) {
            if(notifications_list[i].id === obj.id) {
                notifications_list[i] = General.clone(obj)
                updated_existing_one = true
                break
            }
        }

        // Add new line
        if(!updated_existing_one) {
            notifications_list = [obj].concat(notifications_list)
        }

        // Display OS notification
        displayMessage(obj.title, obj.message)

        // Refresh the list if updated an existing one
        if(updated_existing_one)
            notifications_list = notifications_list
    }

    // Events
    function onUpdateSwapStatus(old_swap_status, new_swap_status, swap_uuid, base_coin, rel_coin, human_date) {
        newNotification({ old_swap_status, new_swap_status, swap_uuid, base_coin, rel_coin, human_date },
                        swap_uuid,
                        base_coin + "/" + rel_coin + " - " + qsTr("Swap status updated"),
                        exchange.getStatusText(old_swap_status) + " " + General.right_arrow_icon + " " + exchange.getStatusText(new_swap_status),
                        human_date,
                        "open_swaps_page")
    }

    function onBalanceUpdateStatus(am_i_sender, amount, ticker, human_date, timestamp) {
        const change = General.formatCrypto("", amount, ticker)
        newNotification({ am_i_sender, amount, ticker, human_date, timestamp },
                        timestamp,
                        am_i_sender ? qsTr("You sent %1").arg(change) : qsTr("You received %1").arg(change),
                        qsTr("Your wallet balance changed"),
                        human_date,
                        "open_wallet_page")
    }


    // System
    Component.onCompleted: {
        API.app.notification_mgr.updateSwapStatus.connect(onUpdateSwapStatus)
        API.app.notification_mgr.balanceUpdateStatus.connect(onBalanceUpdateStatus)
    }

    function displayMessage(title, message) {
        if(API.app.settings_pg.notification_enabled)
            tray.showMessage(title, message)
    }

    SystemTrayIcon {
        id: tray
        visible: true
        iconSource: General.image_path + "tray-icon.png"
        onMessageClicked: {
            performLastNotificationAction()
            showApp()
        }

        tooltip: qsTr("atomicDEX Pro")

//        onActivated: showApp()

        menu: Menu {
            MenuItem {
                text: API.app.settings_pg.empty_string + (qsTr("Show"))
                onTriggered: showApp()
            }

            MenuItem {
                text: API.app.settings_pg.empty_string + (qsTr("Restart"))
                onTriggered: API.app.restart()
            }

            MenuItem {
                text: API.app.settings_pg.empty_string + (qsTr("Quit"))
                onTriggered: Qt.quit()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40

        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            DefaultText {
                text_value: API.app.settings_pg.empty_string + (qsTr("Notifications"))
                font.pixelSize: Style.textSize2
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Rectangle {
                radius: 3

                width: mark_all_as_read.width + 10
                height: mark_all_as_read.height + 10

                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                color: Qt.lighter(Style.colorTheme1, mark_all_as_read_mouse_area.containsMouse ? Style.hoverLightMultiplier : 1.0)

                DefaultText {
                    id: mark_all_as_read
                    text_value: API.app.settings_pg.empty_string + (qsTr("Clear") + " ✔️")
                    font.pixelSize: Style.textSizeSmall3
                    anchors.centerIn: parent
                    color: Style.colorWhite10
                }

                MouseArea {
                    id: mark_all_as_read_mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        notifications_list = []
                    }
                }
            }
        }

        HorizontalLine {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
        }

        InnerBackground {
            Layout.fillWidth: true
            Layout.fillHeight: true

            DefaultText {
                anchors.centerIn: parent
                visible: !list.visible
                text_value: API.app.settings_pg.empty_string + (qsTr("There isn't any notification"))
                font.pixelSize: Style.textSizeSmall2
            }

            DefaultListView {
                id: list

                visible: notifications_list.length !== 0

                anchors.fill: parent
                model: notifications_list

                delegate: Item {
                    width: list.width
                    height: 60

                    DefaultText {
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 25
                        text_value: API.app.settings_pg.empty_string + (modelData.time)
                        font.pixelSize: Style.textSizeSmall
                    }

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        DefaultText {
                            text_value: API.app.settings_pg.empty_string + (modelData.title)
                            font.pixelSize: Style.textSizeSmall4
                            font.bold: true
                        }

                        DefaultText {
                            text_value: API.app.settings_pg.empty_string + (modelData.message)
                            font.pixelSize: Style.textSizeSmall1
                        }
                    }

                    HorizontalLine {
                        visible: index !== notifications_list.length - 1
                        width: parent.width - 4

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -height/2
                        light: true
                    }

                    Rectangle {
                        radius: Style.rectangleCornerRadius

                        width: height
                        height: remove_button.height * 1.2

                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: anchors.bottomMargin + 20

                        color: Qt.lighter(Style.colorTheme1, remove_button_area.containsMouse ? Style.hoverLightMultiplier : 1.0)

                        DefaultText {
                            id: remove_button
                            text_value: API.app.settings_pg.empty_string + ("✔️")
                            anchors.centerIn: parent
                            font.pixelSize: Style.textSizeSmall3
                            color: Style.colorWhite10
                        }

                        MouseArea {
                            id: remove_button_area
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                notifications_list.splice(index, 1)
                                notifications_list = notifications_list
                            }
                        }
                    }
                }
            }
        }


        RowLayout {
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Layout.bottomMargin: parent.spacing
            spacing: 10

//            DefaultButton {
//                text: API.app.settings_pg.empty_string + (qsTr("Pop Test Notification"))
//                onClicked: {
//                    onSwapStatusUpdated("ongoing", "finished", Date.now().toString(), "BTC", "KMD", "13.3.1337")
//                }
//            }

            DefaultButton {
                text: API.app.settings_pg.empty_string + (qsTr("Close"))
                onClicked: root.visible = false
            }
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
