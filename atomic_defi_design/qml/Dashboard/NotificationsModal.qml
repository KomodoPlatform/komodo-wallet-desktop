import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.0
import Qaterial 1.0 as Qaterial

import "../Constants"
import "../Components"

BasicModal {
    id: root

    width: 900

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

    function performNotificationAction(notification) {
        root.close()

        switch(notification.click_action) {
        case "open_notifications":
            root.open()
            break
        case "open_wallet_page":
            api_wallet_page.ticker = notification.params.ticker
            dashboard.current_page = idx_dashboard_wallet
            break
        case "open_swaps_page":
            dashboard.current_page = idx_dashboard_exchange

            dashboard.loader.onLoadComplete = () => {
                dashboard.current_component.current_page = dashboard.isSwapDone(notification.params.new_swap_status) ? idx_exchange_history : idx_exchange_orders
            }
            break
        case "open_log_modal":
            showError(notification.title, notification.long_message)
            break
        default:
            console.log("Unknown notification click action", notification.click_action)
            break
        }
    }

    function newNotification(event_name, params, id, title, message, human_date, click_action = "open_notifications", long_message = "") {
        const obj = { event_name, params, id, title, message, human_date, click_action, long_message }

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
                        getStatusText(old_swap_status) + " " + General.right_arrow_icon + " " + getStatusText(new_swap_status),
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
        // Check if there is mismatch error, ignore this one
        for(let n of notifications_list) {
            if(n.event_name === "onMismatchCustomCoinConfiguration" && n.params.asset === coin) {
                console.log("Ignoring onEnablingCoinFailedStatus event because onMismatchCustomCoinConfiguration exists for", coin)
                return
            }
        }

        // Display the notification
        const title = qsTr("Failed to enable %1", "TICKER").arg(coin)

        error = check_internet_connection_text + "\n\n" + error

        newNotification("onEnablingCoinFailedStatus",
                        { coin, error, human_date, timestamp },
                        timestamp,
                        title,
                        check_internet_connection_text,
                        human_date,
                        "open_log_modal",
                        error)

        toast.show(title, General.time_toast_important_error, error)
    }

    function onEndpointNonReacheableStatus(base_uri, human_date, timestamp) {
        const title = qsTr("Endpoint not reachable")

        const error = qsTr("Could not reach to endpoint") + ". " + check_internet_connection_text + "\n\n" + base_uri

        newNotification("onEndpointNonReacheableStatus",
                        { base_uri, human_date, timestamp },
                        timestamp,
                        title,
                        base_uri,
                        human_date,
                        "open_log_modal",
                        error)

        toast.show(title, General.time_toast_important_error, error)
    }

    function onMismatchCustomCoinConfiguration(asset, human_date, timestamp) {
        const title = qsTr("Mismatch at %1 custom asset configuration", "TICKER").arg(asset)

        newNotification("onMismatchCustomCoinConfiguration",
                        { asset, human_date, timestamp },
                        timestamp,
                        title,
                        qsTr("Application needs to be restarted for %1 custom asset.", "TICKER").arg(asset),
                        human_date)

        toast.show(title, General.time_toast_important_error, "", true, true)
    }

    // System
    Component.onCompleted: {
        API.app.notification_mgr.updateSwapStatus.connect(onUpdateSwapStatus)
        API.app.notification_mgr.balanceUpdateStatus.connect(onBalanceUpdateStatus)
        API.app.notification_mgr.enablingCoinFailedStatus.connect(onEnablingCoinFailedStatus)
        API.app.notification_mgr.endpointNonReacheableStatus.connect(onEndpointNonReacheableStatus)
        API.app.notification_mgr.mismatchCustomCoinConfiguration.connect(onMismatchCustomCoinConfiguration)
    }
    Component.onDestruction: {
        API.app.notification_mgr.updateSwapStatus.disconnect(onUpdateSwapStatus)
        API.app.notification_mgr.balanceUpdateStatus.disconnect(onBalanceUpdateStatus)
        API.app.notification_mgr.enablingCoinFailedStatus.disconnect(onEnablingCoinFailedStatus)
        API.app.notification_mgr.endpointNonReacheableStatus.disconnect(onEndpointNonReacheableStatus)
        API.app.notification_mgr.mismatchCustomCoinConfiguration.disconnect(onMismatchCustomCoinConfiguration)
    }

    function displayMessage(title, message) {
        if(API.app.settings_pg.notification_enabled)
            tray.showMessage(title, message)
    }

    SystemTrayIcon {
        id: tray
        visible: true
        iconSource: General.image_path + "dex-tray-icon.png"
        onMessageClicked: {
            if(notifications_list.length > 0)
                performNotificationAction(notifications_list[0])

            showApp()
        }

        tooltip: API.app_name

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
                        anchors.rightMargin: 200
                        text_value: modelData.human_date
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

                    // Info button
                    Qaterial.AppBarButton {
                        visible: modelData.click_action !== "open_notifications"
                        anchors.verticalCenter: action_button.verticalCenter
                        anchors.right: action_button.left
                        anchors.rightMargin: 15

                        icon.source: General.qaterialIcon("information-variant")
                        onClicked: performNotificationAction(modelData)
                    }

                    // Action button
                    Qaterial.AppBarButton {
                        id: action_button
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
                            case "onMismatchCustomCoinConfiguration":
                                name = "restart-alert"
                                break
                            default:
                                name = "check"
                                break
                            }

                            return General.qaterialIcon(name)
                        }

                        function removeNotification() {
                            notifications_list.splice(index, 1)
                            notifications_list = notifications_list
                        }

                        onClicked: {
                            // Action might create another event so we save it and then remove the current one, then take the action
                            const event_before_removal = General.clone(modelData)

                            // Action
                            switch(event_before_removal.event_name) {
                            case "onEnablingCoinFailedStatus":
                                removeNotification()
                                console.log("Retrying to enable", event_before_removal.params.coin, "asset...")
                                API.app.enable_coins([event_before_removal.params.coin])
                                break
                            case "onMismatchCustomCoinConfiguration":
                                console.log("Restarting for", event_before_removal.params.asset, "custom asset configuration mismatch...")
                                root.close()
                                restart_modal.open()
                                break
                            default:
                                removeNotification()
                                break
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
