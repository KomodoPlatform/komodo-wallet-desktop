import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.0
import Qaterial 1.0 as Qaterial

import "../Constants"
import "../Components"

BasicModal {
    id: root

    width: 800
    property var notifications_list: ([])

    function reset() {
        notifications_list = []
        root.close()
    }

    function showApp() {
        switch(window.real_visibility) {
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

    function performLastNotificationAction() {
        if(notifications_list.length === 0) return

        const notification = notifications_list[0]

        switch(notification.click_action) {
        case "open_notifications":
            root.open()
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

    function newNotification(event_name, params, id, title, message, time, click_action = "open_notifications") {
        const obj = { event_name, params, id, title, message, time, click_action }

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
        newNotification("onUpdateSwapStatus",
                        { old_swap_status, new_swap_status, swap_uuid, base_coin, rel_coin, human_date },
                        swap_uuid,
                        base_coin + "/" + rel_coin + " - " + qsTr("Swap status updated"),
                        exchange.getStatusText(old_swap_status) + " " + General.right_arrow_icon + " " + exchange.getStatusText(new_swap_status),
                        human_date,
                        "open_swaps_page")
    }

    function onBalanceUpdateStatus(am_i_sender, amount, ticker, human_date, timestamp) {
        const change = General.formatCrypto("", amount, ticker)
        newNotification("onBalanceUpdateStatus",
                        { am_i_sender, amount, ticker, human_date, timestamp },
                        timestamp,
                        am_i_sender ? qsTr("You sent %1").arg(change) : qsTr("You received %1").arg(change),
                        qsTr("Your wallet balance changed"),
                        human_date,
                        "open_wallet_page")
    }

    readonly property string check_internet_connection_text: qsTr("Please check your internet connection (e.g. VPN service or firewall might block it).")
    function onEnablingCoinFailedStatus(coin, error, human_date, timestamp) {
        const title = qsTr("Failed to enable %1", "TICKER").arg(coin)

        error = check_internet_connection_text + "\n\n" + error

        newNotification("onEnablingCoinFailedStatus",
                        { coin, error, human_date, timestamp },
                        timestamp,
                        title,
                        qsTr("Please check your internet connection (VPN, Firewall)"),
                        human_date)

        toast.show(title, General.time_toast_important_error, error)
    }

    function onEndpointNonReacheableStatus(base_uri, human_date, timestamp) {
        const title = qsTr("Endpoint not reachable")

        newNotification("onEndpointNonReacheableStatus",
                        { base_uri, human_date, timestamp },
                        timestamp,
                        title,
                        base_uri.length <= 25 ? base_uri : base_uri.substring(0, 25) + "...",
                        human_date)

        toast.show(title, General.time_toast_important_error, qsTr("Could not reach to endpoint") + ". " + check_internet_connection_text + "\n\n" + base_uri)
    }

    // System
    Component.onCompleted: {
        API.app.notification_mgr.updateSwapStatus.connect(onUpdateSwapStatus)
        API.app.notification_mgr.balanceUpdateStatus.connect(onBalanceUpdateStatus)
        API.app.notification_mgr.enablingCoinFailedStatus.connect(onEnablingCoinFailedStatus)
        API.app.notification_mgr.endpointNonReacheableStatus.connect(onEndpointNonReacheableStatus)
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

        tooltip: qsTr("AtomicDEX Desktop")

//        onActivated: showApp()

        menu: Menu {
            MenuItem {
                text: qsTr("Show")
                onTriggered: showApp()
            }

            MenuItem {
                text: qsTr("Restart")
                onTriggered: API.app.restart()
            }

            MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }
    }

    ModalContent {
        title: qsTr("Notifications")

        Qaterial.AppBarButton {
            visible: list.visible

            icon.source: General.qaterialIcon("check-all")
            onClicked: notifications_list = []
        }

        InnerBackground {
            Layout.fillWidth: true

            Layout.preferredHeight: 500

            DefaultText {
                anchors.centerIn: parent
                visible: !list.visible
                text_value: qsTr("There isn't any notification")
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
                        text_value: modelData.time
                        font.pixelSize: Style.textSizeSmall
                    }

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        DefaultText {
                            text_value: modelData.title
                            font.pixelSize: Style.textSizeSmall4
                            font.weight: Font.Medium
                        }

                        DefaultText {
                            text_value: modelData.message
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

                    Qaterial.AppBarButton {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: anchors.bottomMargin + 20

                        icon.source: {
                            let name
                            switch(modelData.event_name) {
                            case "onEnablingCoinFailedStatus":
                                name = "repeat"
                                break
                            default:
                                name = "check"
                                break
                            }

                            return General.qaterialIcon(name)
                        }
                        onClicked: {
                            // Action might create another event so we save it and then remove the current one, then take the action
                            const event_before_removal = General.clone(modelData)

                            // Remove notification
                            notifications_list.splice(index, 1)
                            notifications_list = notifications_list

                            // Action
                            if(event_before_removal.event_name === "onEnablingCoinFailedStatus") {
                                console.log("Retrying to enable", event_before_removal.params.coin, "asset...")
                                API.app.enable_coins([event_before_removal.params.coin])
                            }
                        }
                    }
                }
            }
        }


        footer: [
            DefaultButton {
                Layout.fillWidth: true
                text: qsTr("Close")
                onClicked: root.close()
            }
        ]
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
