import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.0
import Qaterial 1.0 as Qaterial
import ModelHelper 0.1

import Dex.Themes 1.0 as Dex

import "../Constants"
import App 1.0
import "../Components"
import "../Screens"

DexPopup
{
    id: root
    property var orders: API.app.orders_mdl.orders_proxy_mdl.ModelHelper

    width: 406
    height: 526
    property
    var default_gradient: Gradient
    {
        orientation: Qt.Horizontal
        GradientStop
        {
            position: 0.1255
            color: Dex.CurrentTheme.gradientButtonPressedStartColor
        }
        GradientStop
        {
            position: 0.933
            color: Dex.CurrentTheme.gradientButtonPressedEndColor
        }
    }
    property
    var default_red_gradient: Gradient
    {
        orientation: Qt.Horizontal
        GradientStop
        {
            position: 0.1255
            color: Dex.CurrentTheme.tradeSellModeSelectorBackgroundColorStart
        }
        GradientStop
        {
            position: 0.933
            color: Dex.CurrentTheme.tradeSellModeSelectorBackgroundColorEnd
        }
    }
    property
    var notification_map: [
    {
        icon: Qaterial.Icons.arrowTopRight,
        color: Dex.CurrentTheme.foregroundColor,
        gradient: default_red_gradient
    },
    {
        icon: Qaterial.Icons.arrowBottomRight,
        color: Dex.CurrentTheme.foregroundColor,
        gradient: default_gradient
    },
    {
        icon: Qaterial.Icons.messageOutline,
        color: Dex.CurrentTheme.foregroundColor,
        gradient: default_gradient
    }]
    backgroundColor: Dex.CurrentTheme.floatingBackgroundColor

    function reset()
    {
        notifications_list = []
        root.close()
    }
    enum NotificationKind
    {
        Send,
        Receive,
        Others
    }

    function showApp()
    {
        switch (window.real_visibility)
        {
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

    function performNotificationAction(notification)
    {
        root.close()

        switch (notification.click_action)
        {
            case "open_notifications":
                root.open()
                break
            case "open_wallet_page":
                API.app.wallet_pg.ticker = notification.params.ticker
                app.pageLoader.item.switchPage(Dashboard.PageType.Wallet)
                break
            case "open_swaps_page":
                app.pageLoader.item.switchPage(Dashboard.PageType.DEX)
                break
            case "open_log_modal":
                showError(notification.title, notification.long_message)
                break
            default:
                console.warn("Unknown notification click action", notification.click_action)
                break
        }
    }

    function newNotification(event_name, params, id, title, message, human_date, click_action = "open_notifications", long_message = "")
    {

        let obj;
        if (title.indexOf("You received") !== -1)
        {
            obj = {
                event_name,
                params,
                id,
                title,
                message,
                human_date,
                click_action,
                long_message,
                kind: NotificationsModal.NotificationKind.Receive
            }
        }
        else if (title.indexOf("You sent") !== -1)
        {
            obj = {
                event_name,
                params,
                id,
                title,
                message,
                human_date,
                click_action,
                long_message,
                kind: NotificationsModal.NotificationKind.Send
            }
        }
        else
        {
            obj = {
                event_name,
                params,
                id,
                title,
                message,
                human_date,
                click_action,
                long_message,
                kind: NotificationsModal.NotificationKind.Others
            }
        }

        // Update if it already exists
        let updated_existing_one = false
        for (let i = 0; i < notifications_list.length; ++i)
        {
            if (notifications_list[i].id === obj.id)
            {
                notifications_list[i] = General.clone(obj)
                updated_existing_one = true
                break
            }
        }

        // Add new line
        if (!updated_existing_one)
        {
            notifications_list = [obj].concat(notifications_list)
        }

        // Display OS notification
        displayMessage(obj.title, obj.message)

        // Refresh the list if updated an existing one
        if (updated_existing_one)
            notifications_list = notifications_list
    }


    function getOrderStatusText(status, short_text = false)
    {
        switch (status)
        {
            case "matching":
                return short_text ? qsTr("Matching") : qsTr("Order Matching")
            case "matched":
                return short_text ? qsTr("Matched") : qsTr("Order Matched")
            case "ongoing":
                return short_text ? qsTr("Ongoing") : qsTr("Swap Ongoing")
            case "successful":
                return short_text ? qsTr("Successful") : qsTr("Swap Successful")
            case "refunding":
                return short_text ? qsTr("Refunding") : qsTr("Refunding")
            case "failed":
                return short_text ? qsTr("Failed") : qsTr("Swap Failed")
            default:
                return short_text ? qsTr("Unknown") : qsTr("Unknown State")
        }
    }

    // Events
    function onUpdateSwapStatus(old_swap_status, new_swap_status, swap_uuid, base_coin, rel_coin, human_date)
    {
        newNotification("onUpdateSwapStatus",
            {
                old_swap_status,
                new_swap_status,
                swap_uuid,
                base_coin,
                rel_coin,
                human_date
            },
            swap_uuid,
            base_coin + "/" + rel_coin + " - " + qsTr("Swap status updated"),
            getOrderStatusText(old_swap_status) + " " + General.right_arrow_icon + " " + getOrderStatusText(new_swap_status),
            human_date,
            "open_swaps_page")
    }

    function onBalanceUpdateStatus(am_i_sender, amount, ticker, human_date, timestamp)
    {
        const change = General.formatFullCrypto("", amount, ticker, "", "", true)
        if (!app.segwit_on)
        {
            if (amount != 0)
            {
            newNotification("onBalanceUpdateStatus",
                {
                    am_i_sender,
                    amount,
                    ticker,
                    human_date,
                    timestamp
                },
                timestamp,
                am_i_sender ? qsTr("You sent %1").arg(change) : qsTr("You received %1").arg(change),
                qsTr("Your wallet balance changed"),
                human_date,
                "open_wallet_page")
            }
        }
        else
        {
            app.segwit_on = false
        }
    }

    function onEnablingZCoinStatus(coin, msg, human_date, timestamp)
    {
        // Ignore if coin already enabled (e.g. parent chain in batch)
        if (msg.search("already initialized") > -1)
        {
            console.trace()
            return
        }

        // Display the notification
        const title = qsTr(" %1 Enable status", "TICKER").arg(coin)

        newNotification("onEnablingZCoinStatus",
            {
                coin,
                human_date,
                timestamp
            },
            timestamp,
            title,
            msg,
            human_date,
            "open_log_modal",
            msg)
    }

    readonly property string check_internet_connection_text: qsTr("Please check your internet connection (e.g. VPN service or firewall might block it).")
    function onEnablingCoinFailedStatus(coin, error, human_date, timestamp)
    {
        // Ignore if coin already enabled (e.g. parent chain in batch)
        if (error.search("already initialized") > -1)
        {
            console.trace()
            return
        }

        // Check if there is mismatch error, ignore this one
        for (let n of notifications_list)
        {
            if (n.event_name === "onMismatchCustomCoinConfiguration" && n.params.asset === coin)
            {
                console.trace()
                return
            }
        }

        // Display the notification
        const title = qsTr("Failed to enable %1", "TICKER").arg(coin)

        error = check_internet_connection_text + "\n\n" + error

        newNotification("onEnablingCoinFailedStatus",
            {
                coin,
                error,
                human_date,
                timestamp
            },
            timestamp,
            title,
            check_internet_connection_text,
            human_date,
            "open_log_modal",
            error)

        toast.show(title, General.time_toast_important_error, error)
    }

    function onDisablingCoinFailedStatus(coin, error, human_date, timestamp)
    {
        const title = qsTr("Failed to disable %1", "TICKER").arg(coin)

        newNotification("onDisablingCoinFailedStatus",
            {
                coin,
                error,
                human_date,
                timestamp
            },
            timestamp,
            title,
            human_date,
            "open_log_modal",
            error)
        toast.show(title, General.time_toast_important_error, error)
    }

    function onEndpointNonReacheableStatus(base_uri, human_date, timestamp)
    {
        const title = qsTr("Endpoint not reachable")

        const error = qsTr("Could not reach to endpoint") + ". " + check_internet_connection_text + "\n\n" + base_uri

        newNotification("onEndpointNonReacheableStatus",
            {
                base_uri,
                human_date,
                timestamp
            },
            timestamp,
            title,
            base_uri,
            human_date,
            "open_log_modal",
            error)

        toast.show(title, General.time_toast_important_error, error)
    }

    function onMismatchCustomCoinConfiguration(asset, human_date, timestamp)
    {
        const title = qsTr("Mismatch at %1 custom asset configuration", "TICKER").arg(asset)

        newNotification("onMismatchCustomCoinConfiguration",
            {
                asset,
                human_date,
                timestamp
            },
            timestamp,
            title,
            qsTr("Application needs to be restarted for %1 custom asset.", "TICKER").arg(asset),
            human_date)

        toast.show(title, General.time_toast_important_error, "", true, true)
    }

    function onBatchFailed(reason, from, human_date, timestamp)
    {
        const title = qsTr("Batch %1 failed. Reason: %2").arg(from).arg(reason)

        newNotification("onBatchFailed",
            {
                human_date,
                timestamp
            },
            timestamp,
            title,
            reason,
            human_date)

        toast.show(title, General.time_toast_important_error, reason)
    }

    // System
    Component.onCompleted:
    {
        API.app.notification_mgr.updateSwapStatus.connect(onUpdateSwapStatus)
        API.app.notification_mgr.balanceUpdateStatus.connect(onBalanceUpdateStatus)
        API.app.notification_mgr.enablingZCoinStatus.connect(onEnablingZCoinStatus)
        API.app.notification_mgr.enablingCoinFailedStatus.connect(onEnablingCoinFailedStatus)
        API.app.notification_mgr.disablingCoinFailedStatus.connect(onDisablingCoinFailedStatus)
        API.app.notification_mgr.endpointNonReacheableStatus.connect(onEndpointNonReacheableStatus)
        API.app.notification_mgr.mismatchCustomCoinConfiguration.connect(onMismatchCustomCoinConfiguration)
        API.app.notification_mgr.batchFailed.connect(onBatchFailed)
    }
    Component.onDestruction:
    {
        API.app.notification_mgr.updateSwapStatus.disconnect(onUpdateSwapStatus)
        API.app.notification_mgr.balanceUpdateStatus.disconnect(onBalanceUpdateStatus)
        API.app.notification_mgr.enablingZCoinStatus.disconnect(onEnablingZCoinStatus)
        API.app.notification_mgr.enablingCoinFailedStatus.disconnect(onEnablingCoinFailedStatus)
        API.app.notification_mgr.disablingCoinFailedStatus.disconnect(onDisablingCoinFailedStatus)
        API.app.notification_mgr.endpointNonReacheableStatus.disconnect(onEndpointNonReacheableStatus)
        API.app.notification_mgr.mismatchCustomCoinConfiguration.disconnect(onMismatchCustomCoinConfiguration)
        API.app.notification_mgr.batchFailed.disconnect(onBatchFailed)
    }

    function displayMessage(title, message)
    {
        if (API.app.settings_pg.notification_enabled)
            tray.showMessage(title, message)
    }

    SystemTrayIcon
    {
        id: tray
        visible: true
        iconSource: General.image_path + "dex-tray-icon.png"

        tooltip: API.app_name

        onMessageClicked:
        {
            if (notifications_list.length > 0)
                performNotificationAction(notifications_list[0])
            showApp()
        }

        menu: Menu
        {
            MenuItem
            {
                text: qsTr("Show")
                onTriggered: showApp()
            }

            MenuItem
            {
                text: qsTr("Restart")
                onTriggered: API.app.restart()
            }

            MenuItem
            {
                text: qsTr("Quit")
                onTriggered:
                {
                    if (orders.count != 0) logout_modal.open()
                    else return_to_login()
                }
            }
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: 30
        anchors.topMargin: 20
        spacing: 24

        DefaultText
        {
            Layout.fillWidth: true
            font
            {
                pixelSize: 20
                weight: Font.Normal
            }
            text: qsTr("Notifications")
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Qaterial.Icon
            {

                anchors.centerIn: parent
                icon: Qaterial.Icons.bellOutline
                size: 166
                opacity: 0.03

            }

            DefaultText
            {
                anchors.centerIn: parent
                visible: !list.visible
                text_value: qsTr("There aren't any notifications")
                font.pixelSize: 14
            }

            DefaultListView
            {
                id: list
                visible: notifications_list.length !== 0
                width: parent.width + 58
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                model: notifications_list

                delegate: Item
                {
                    height: _column.height + 10
                    width: list.width

                    Rectangle
                    {
                        anchors.fill: parent
                        opacity: 0.7

                        gradient: Gradient
                        {
                            orientation: Qt.Horizontal
                            GradientStop
                            {
                                position: 0.1255
                                color: mouseArea.containsMouse ? Dex.CurrentTheme.buttonColorEnabled : 'transparent'
                            }
                            GradientStop
                            {
                                position: 0.933
                                color: 'transparent'
                            }
                        }
                    }

                    function removeNotification()
                    {
                        notifications_list.splice(index, 1)
                        notifications_list = notifications_list
                    }

                    RowLayout
                    {
                        anchors.fill: parent
                        Item
                        {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 60

                            Rectangle
                            {
                                width: 23
                                height: 23
                                radius: 12
                                gradient: notification_map[modelData.kind].gradient
                                anchors.right: parent.right
                                anchors.rightMargin: -5
                                y: 13
                                
                                Qaterial.Icon
                                {
                                    anchors.centerIn: parent
                                    size: 16
                                    icon: notification_map[modelData.kind].icon
                                }
                            }
                        }

                        Item
                        {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Column
                            {
                                id: _column
                                width: parent.width
                                leftPadding: 15
                                topPadding: 10
                                bottomPadding: 5
                                spacing: 5

                                DefaultText
                                {
                                    text: modelData.title
                                    font: DexTypo.subtitle1
                                    width: parent.width
                                    wrapMode: Label.Wrap
                                }

                                DefaultText
                                {
                                    text: modelData.message
                                    font: DexTypo.subtitle2
                                    width: parent.width - 20
                                    wrapMode: Label.Wrap
                                }

                                DefaultText
                                {
                                    text: modelData.human_date
                                    font: DexTypo.caption
                                    opacity: 0.7
                                }
                            }

                            Qaterial.AppBarButton
                            {
                                id: action_button
                                scale: .6
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.rightMargin: 5
                                anchors.bottomMargin: -4
                                foregroundColor: Dex.CurrentTheme.foregroundColor
                                visible: modelData.event_name !== "check"

                                icon.source:
                                {
                                    let name
                                    switch (modelData.event_name)
                                    {
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

                                function removeNotification()
                                {
                                    notifications_list.splice(index, 1)
                                    notifications_list = notifications_list
                                }

                                onClicked:
                                {
                                    // Action might create another event so we save it and then remove the current one, then take the action
                                    const event_before_removal = General.clone(modelData)

                                    // Action
                                    switch (event_before_removal.event_name)
                                    {
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

                    DefaultMouseArea
                    {
                        id: mouseArea
                        hoverEnabled: true
                        cursorShape: "PointingHandCursor"
                        anchors.fill: parent

                        onClicked:
                        {
                            performNotificationAction(notifications_list[index])
                            removeNotification()
                        }
                    }
                }
            }
        }

        OutlineButton
        {
            text: qsTr('Mark all as read')
            height: 40
            width: 260
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.reset()
        }
    }
}
