import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"
import Dex.Themes 1.0 as Dex
import App 1.0

MultipageModal
{
    id: root

    property var details

    onDetailsChanged: { if (!details) root.close() }
    onOpened: swap_progress.updateSimulatedTime()
    onClosed: details = undefined

    MultipageModalContent
    {
        titleText: !details ? "" : details.is_swap ? qsTr("Swap Details") : qsTr("Order Details")
        titleAlignment: Qt.AlignHCenter

        // Complete image
        DefaultImage
        {
            visible: !details ? false : details.is_swap && details.order_status === "successful"
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "exchange-trade-complete.png"
        }

        // Loading symbol
        DefaultBusyIndicator
        {
            visible: !details ? false : details.is_swap && details.order_status !== "successful"
            running: (!details ? false :
                details.is_swap &&
                details.order_status !== "successful" &&
                details.order_status !== "failed") && Qt.platform.os != "osx"
            Layout.alignment: Qt.AlignHCenter
        }

        // Status Text
        DefaultText
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 5
            font.pixelSize: Style.textSize1
            font.bold: true 
            visible: !details ? false : details.is_swap || !details.is_maker
            text_value: !details ? "" : visible ? getStatusText(details.order_status) : ''
        }

        RowLayout
        {
            Layout.topMargin: 22

            DefaultRectangle
            {
                Layout.preferredWidth: 226
                Layout.preferredHeight: 66
                radius: 10

                RowLayout
                {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 23

                    DefaultImage
                    {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignVCenter

                        source: General.coinIcon(!details ? atomic_app_primary_coin : details.base_coin)
                    }

                    ColumnLayout
                    {
                        Layout.fillWidth: true
                        RowLayout
                        {
                            Layout.fillWidth: true
                            spacing: 5
                            DefaultText
                            {
                                Layout.fillWidth: true
                                text: details ? details.base_coin : ""
                            }

                            DefaultText
                            {
                                Layout.fillWidth: true
                                text: details ? General.coinName(details.base_coin) : ""
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                font.pixelSize: 11
                            }
                        }

                        DefaultText
                        {
                            Layout.fillWidth: true
                            text: details ? details.base_amount : ""
                            font.pixelSize: 11
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Qaterial.Icon
            {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                color: Dex.CurrentTheme.foregroundColor
                icon: Qaterial.Icons.swapHorizontal
            }

            DefaultRectangle
            {
                Layout.preferredWidth: 226
                Layout.preferredHeight: 66
                radius: 10

                RowLayout
                {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 23

                    DefaultImage
                    {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignVCenter

                        source: General.coinIcon(!details ? atomic_app_primary_coin : details.rel_coin)
                    }

                    ColumnLayout
                    {
                        Layout.fillWidth: true
                        RowLayout
                        {
                            Layout.fillWidth: true
                            spacing: 5
                            DefaultText
                            {
                                Layout.fillWidth: true
                                text: details ? details.rel_coin : ""
                            }

                            DefaultText
                            {
                                Layout.fillWidth: true
                                text: details ? General.coinName(details.rel_coin) : ""
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                font.pixelSize: 11
                            }
                        }

                        DefaultText
                        {
                            Layout.fillWidth: true
                            text: details ? details.rel_amount : ""
                            font.pixelSize: 11
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        DefaultScrollView
        {
            Layout.topMargin: 20
            Layout.fillWidth: true
            Layout.preferredHeight: 300

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout
            {
                width: 400
                height: parent.height - 30
                spacing: 12

                // Maker/Taker
                TextEditWithTitle
                {
                    Layout.fillWidth: true
                    title: qsTr("Order Type")
                    text: !details ? "" : details.is_maker ? qsTr("Maker Order") : qsTr("Taker Order")
                    label.font.pixelSize: 13
                }

                // Refund state
                TextFieldWithTitle
                {
                    Layout.fillWidth: true
                    title: qsTr("Refund State")
                    field.text: !details ? "" : details.order_status === "refunding" ? qsTr("Your swap failed but the auto-refund process for your payment started already. Please wait and keep application opened until you receive your payment back") : ""
                    field.readOnly: true
                    field.font.pixelSize: 13
                    visible: field.text !== ''
                }

                // Date
                TextEditWithTitle
                {
                    Layout.fillWidth: true
                    title: qsTr("Date")
                    text: !details ? "" : details.date
                    label.font.pixelSize: 13
                    visible: text !== ''
                }

                // ID
                TextEditWithTitle
                {
                    Layout.fillWidth: true
                    title: qsTr("ID")
                    text: !details ? "" : details.order_id
                    label.font.pixelSize: 13
                    visible: text !== ''
                    copy: true
                    privacy: true
                }

                // Payment ID
                TextEditWithTitle
                {
                    Layout.fillWidth: true
                    title: !details ? "" : details.is_maker ? qsTr("Maker Payment Sent ID") : qsTr("Maker Payment Spent ID")
                    text: !details ? "" : details.maker_payment_id
                    label.font.pixelSize: 13
                    visible: text !== ''
                    privacy: true
                }

                // Payment ID
                TextEditWithTitle
                {
                    Layout.fillWidth: true
                    title: !details ? "" : details.is_maker ? qsTr("Taker Payment Spent ID") : qsTr("Taker Payment Sent ID")
                    text: !details ? "" : details.taker_payment_id
                    label.font.pixelSize: 13
                    visible: text !== ''
                    privacy: true
                }

                // Error ID
                TextEditWithTitle
                {
                    Layout.fillWidth: true
                    title: qsTr("Error ID")
                    text: !details ? "" : details.order_error_state
                    label.font.pixelSize: 13
                    visible: text !== ''
                }

                // Error Details
                TextEditWithTitle
                {
                    Layout.fillWidth: true
                    title: qsTr("Error Log")
                    text: !details ? "" : details.order_error_message
                    label.font.pixelSize: 13
                    visible: text !== ''
                    copy: true
                    onCopyNotificationTitle: qsTr("Error Log")
                }

                HorizontalLine
                {
                    visible: swap_progress.visible
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                }

                SwapProgress
                {
                    id: swap_progress
                    visible: General.exists(details) && details.order_status !== "matching"
                    Layout.fillWidth: true
                    details: root.details
                }
            }
        }

        // Buttons
        footer:
        [
            DexAppButton
            {
                text: qsTr("Close")
                leftPadding: 20
                rightPadding: 20
                radius: 18
                onClicked: root.close()
            },

            // Cancel button
            DexAppOutlineButton
            {
                id: cancelOrderButton
                visible: !details ? false : details.cancellable
                leftPadding: 20
                rightPadding: 20
                radius: 18
                text: qsTr("Cancel Order")
                onClicked: cancelOrder(details.order_id)
            },

            Item
            {
                visible: !cancelOrderButton.visible
                Layout.fillWidth: true
            },

            // Recover Funds button
            DexAppButton
            {
                id: refundButton
                leftPadding: 20
                rightPadding: 20
                radius: 18
                enabled: !API.app.orders_mdl.recover_fund_busy
                visible: !details ? false :
                    details.recoverable && details.order_status !== "refunding"
                text: enabled ? qsTr("Recover Funds") : qsTr("Refunding...")
                onClicked: API.app.orders_mdl.recover_fund(details.order_id)
            },

            Item
            {
                visible: !refundButton.visible & !cancelOrderButton.visible
                Layout.fillWidth: true
            },

            DexAppOutlineButton
            {
                text: qsTr("View on Explorer")
                leftPadding: 20
                rightPadding: 20
                radius: 18
                visible: !details ? false : details.maker_payment_id !== '' || details.taker_payment_id !== ''
                onClicked:
                {
                    if (!details) return

                    const maker_id = details.maker_payment_id
                    const taker_id = details.taker_payment_id

                    if (maker_id !== '') General.viewTxAtExplorer(details.is_maker ? details.base_coin : details.rel_coin, maker_id)
                    if (taker_id !== '') General.viewTxAtExplorer(details.is_maker ? details.rel_coin : details.base_coin, taker_id)
                }
            }
        ]
    }
}
