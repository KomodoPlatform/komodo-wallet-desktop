import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    width: 900
    height: Math.min(header.height + inner_layout.height + footer.height + root.padding*2 + outer_layout.spacing*2, window.height - 90)

    property var details

    onDetailsChanged: {
        if(!details) root.close()
    }

    onClosed: details = undefined

    // Inside modal
    ColumnLayout {
        id: outer_layout
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        ModalHeader {
            id: header
            title: API.get().settings_pg.empty_string + (!details ? "" :
                                                        details.is_swap ? qsTr("Swap Details") : qsTr("Order Details"))
        }

        DefaultFlickable {
            Layout.fillWidth: true
            Layout.fillHeight: true

            contentWidth: inner_layout.width
            contentHeight: inner_layout.height

            ColumnLayout {
                id: inner_layout
                width: root.width - root.padding*2 - 20 // Scrollbar margin

                // Complete image
                DefaultImage {
                    visible: !details ? false :
                                        details.is_swap && details.order_status === "successful"
                    Layout.alignment: Qt.AlignHCenter
                    source: General.image_path + "exchange-trade-complete.svg"
                }

                // Loading symbol
                DefaultBusyIndicator {
                    visible: !details ? false :
                                         details.is_swap &&
                                         details.order_status !== "successful" &&
                                         details.order_status !== "failed"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Status Text
                DefaultText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    font.pixelSize: Style.textSize3
                    visible: !details ? false :
                                        details.is_swap || !details.is_maker
                    color: !details ? "white" :
                                      visible ? getStatusColor(details.order_status) : ''
                    text_value: API.get().settings_pg.empty_string + (!details ? "" :
                                                                     visible ? getStatusTextWithPrefix(details.order_status) : '')
                }

                OrderContent {
                    Layout.topMargin: 25
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: Layout.leftMargin
                    height: 120
                    Layout.alignment: Qt.AlignHCenter
                    details: root.details
                    in_modal: true
                }

                HorizontalLine {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 20
                    color: Style.colorWhite8
                }

                // Maker/Taker
                DefaultText {
                    text_value: API.get().settings_pg.empty_string + (!details ? "" :
                                                                     details.is_maker ? qsTr("Maker Order"): qsTr("Taker Order"))
                    color: Style.colorThemeDarkLight
                    Layout.alignment: Qt.AlignRight
                }

                // Refund state
                TextFieldWithTitle {
                    Layout.topMargin: -20

                    title: API.get().settings_pg.empty_string + (qsTr("Refund State"))
                    field.text: !details ? "" :
                                           details.order_status === "refunding" ? qsTr("Your swap failed but the auto-refund process for your payment started already. Please wait and keep application opened until you receive your payment back") : ""
                    field.readOnly: true

                    visible: field.text !== ''
                }

                // Date
                TextWithTitle {
                    title: API.get().settings_pg.empty_string + (qsTr("Date"))
                    text: API.get().settings_pg.empty_string + (!details ? "" :
                                                               details.date)
                    visible: text !== ''
                }

                // ID
                TextWithTitle {
                    title: API.get().settings_pg.empty_string + (qsTr("ID"))
                    text: API.get().settings_pg.empty_string + (!details ? "" :
                                                               details.order_id)
                    visible: text !== ''
                    privacy: true
                }

                // Payment ID
                TextWithTitle {
                    title: API.get().settings_pg.empty_string + (!details ? "" :
                                                                details.is_maker ? qsTr("Maker Payment Sent ID") : qsTr("Maker Payment Spent ID"))
                    text: API.get().settings_pg.empty_string + (!details ? "" :
                                                               details.maker_payment_id)
                    visible: text !== ''
                    privacy: true
                }

                // Payment ID
                TextWithTitle {
                    title: API.get().settings_pg.empty_string + (!details ? "" :
                                                                details.is_maker ? qsTr("Taker Payment Spent ID") : qsTr("Taker Payment Sent ID"))
                    text: API.get().settings_pg.empty_string + (!details ? "" :
                                                               details.taker_payment_id)
                    visible: text !== ''
                    privacy: true
                }

                // Error ID
                TextWithTitle {
                    title: API.get().settings_pg.empty_string + (qsTr("Error ID"))
                    text: API.get().settings_pg.empty_string + (!details ? "" :
                                                               details.order_error_state)
                    visible: text !== ''
                }

                // Error Details
                TextFieldWithTitle {
                    title: API.get().settings_pg.empty_string + (qsTr("Error Log"))
                    field.text: API.get().settings_pg.empty_string + (!details ? "" :
                                                                     details.order_error_message)
                    field.readOnly: true
                    copyable: true

                    visible: field.text !== ''
                }

                HorizontalLine {
                    visible: swap_progress.visible
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: Layout.topMargin
                    color: Style.colorWhite8
                }

                SwapProgress {
                    id: swap_progress
                    visible: General.exists(details) && details.order_status !== "matching"
                    Layout.fillWidth: true
                    details: root.details
                }
            }
        }

        // Buttons
        RowLayout {
            id: footer
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            // Cancel button
            DangerButton {
                visible: !details ? false :
                                    details.cancellable
                Layout.fillWidth: true
                text: API.get().settings_pg.empty_string + (qsTr("Cancel Order"))
                onClicked: { if(details) onCancelOrder(details.order_id) }
            }

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("View at Explorer"))
                Layout.fillWidth: true
                visible: !details ? false :
                                    details.maker_payment_id !== '' || details.taker_payment_id !== ''
                onClicked: {
                    if(!details) return

                    const maker_id = details.maker_payment_id
                    const taker_id = details.taker_payment_id

                    if(maker_id !== '') General.viewTxAtExplorer(details.is_maker ? details.base_coin : details.rel_coin, maker_id)
                    if(taker_id !== '') General.viewTxAtExplorer(details.is_maker ? details.rel_coin : details.base_coin, taker_id)
                }
            }
        }
    }
}
