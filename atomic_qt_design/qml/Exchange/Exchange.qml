import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"
import "./Trade"
import "./Orders"
import "./History"

Item {
    id: exchange
    readonly property int layout_margin: 15

    property int prev_page: -1
    property int current_page: API.design_editor ? General.idx_exchange_trade : General.idx_exchange_trade

    function reset() {
        current_page = General.idx_exchange_trade
        prev_page = -1
        exchange_trade.fullReset()
        exchange_history.reset()
        exchange_orders.reset()
    }

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === General.idx_dashboard_exchange
    }

    function openTradeView(ticker) {
        exchange_trade.open(ticker)
    }

    function onTradeTickerChanged(ticker) {
        exchange_orders.changeTicker(ticker)
    }

    function onOpened() {
        if(prev_page !== current_page) {
            // Handle DEX enter/exit
            if(current_page === General.idx_exchange_trade) {
                API.get().trading_pg.on_gui_enter_dex()
                exchange_trade.onOpened()
            }
            else if(prev_page === General.idx_exchange_trade) {
                API.get().trading_pg.on_gui_leave_dex()
            }

            // Opening of other pages
            if(current_page === General.idx_exchange_orders) {
                exchange_orders.onOpened()
            }
            else if(current_page === General.idx_exchange_history) {
                exchange_history.onOpened()
            }
        }

        prev_page = current_page
    }

    onCurrent_pageChanged: {
        onOpened()
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        anchors.fill: parent

        spacing: layout_margin

        // Top tabs
        FloatingBackground {
            id: balance_box
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.topMargin: layout_margin
            Layout.rightMargin: layout_margin

            content: Item {
                id: content
                width: balance_box.width
                height: 62

                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 30

                    ExchangeTab {
                        dashboard_index: General.idx_exchange_trade
                        text_value: API.get().settings_pg.empty_string + (qsTr("Trade"))
                    }

                    VerticalLineBasic {
                        id: vline
                        height: content.height * 0.5
                        color: Style.colorTheme5
                    }

                    ExchangeTab {
                        dashboard_index: General.idx_exchange_orders
                        text_value: API.get().settings_pg.empty_string + (qsTr("Orders"))
                    }

                    VerticalLineBasic {
                        height: vline.height
                        color: vline.color
                    }

                    ExchangeTab {
                        dashboard_index: General.idx_exchange_history
                        text_value: API.get().settings_pg.empty_string + (qsTr("History"))
                    }
                }
            }
        }

        // Bottom content
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: layout_margin
            Layout.rightMargin: Layout.bottomMargin

            currentIndex: current_page

            Trade {
                id: exchange_trade

                onOrderSuccess: () => {
                    General.prevent_coin_disabling.restart()
                    exchange_trade.reset(false)
                    exchange.current_page = General.idx_exchange_orders
                    exchange_orders.onOrderPlaced()
                }
            }

            Orders {
                id: exchange_orders
            }

            History {
                id: exchange_history
            }
        }
    }

    function getStatusColor(status) {
        switch(status) {
            case "matching":
                return Style.colorYellow
            case "matched":
            case "ongoing":
            case "refunding":
                return Style.colorOrange
            case "successful":
                return Style.colorGreen
            case "failed":
            default:
                return Style.colorRed
        }
    }

    function getStatusText(status) {
        switch(status) {
            case "matching":
                return qsTr("Order Matching")
            case "matched":
                return qsTr("Order Matched")
            case "ongoing":
                return qsTr("Swap Ongoing")
            case "successful":
                return qsTr("Swap Successful")
            case "refunding":
                return qsTr("Refunding")
            case "failed":
                return qsTr("Swap Failed")
            default:
                return qsTr("Unknown State")
        }
    }

    function getStatusStep(status) {
        switch(status) {
            case "matching":
                return "0/3"
            case "matched":
                return "1/3"
            case "ongoing":
                return "2/3"
            case "successful":
                return Style.successCharacter
            case "refunding":
            case "failed":
                return Style.failureCharacter
            default:
                return "?"
        }
    }

    function getStatusTextWithPrefix(status) {
        return getStatusStep(status) + " " + getStatusText(status)
    }

    function getEventText(event_name) {
        switch(event_name) {
            case "Started":
                return qsTr("Started")
            case "Negotiated":
                return qsTr("Negotiated")
            case "TakerFeeSent":
                return qsTr("Taker fee sent")
            case "MakerPaymentReceived":
                return qsTr("Maker payment received")
            case "MakerPaymentWaitConfirmStarted":
                return qsTr("Maker payment wait confirm started")
            case "MakerPaymentValidatedAndConfirmed":
                return qsTr("Maker payment validated and confirmed")
            case "TakerPaymentSent":
                return qsTr("Taker payment sent")
            case "TakerPaymentSpent":
                return qsTr("Taker payment spent")
            case "MakerPaymentSpent":
                return qsTr("Maker payment spent")
            case "Finished":
                return qsTr("Finished")
            case "StartFailed":
                return qsTr("Start failed")
            case "NegotiateFailed":
                return qsTr("Negotiate failed")
            case "TakerFeeValidateFailed":
                return qsTr("Taker fee validate failed")
            case "MakerPaymentTransactionFailed":
                return qsTr("Maker payment transaction failed")
            case "MakerPaymentDataSendFailed":
                return qsTr("Maker payment Data send failed")
            case "MakerPaymentWaitConfirmFailed":
                return qsTr("Maker payment wait confirm failed")
            case "TakerPaymentValidateFailed":
                return qsTr("Taker payment validate failed")
            case "TakerPaymentWaitConfirmFailed":
                return qsTr("Taker payment wait confirm failed")
            case "TakerPaymentSpendFailed":
                return qsTr("Taker payment spend failed")
            case "MakerPaymentWaitRefundStarted":
                return qsTr("Maker payment wait refund started")
            case "MakerPaymentRefunded":
                return qsTr("Maker payment refunded")
            case "MakerPaymentRefundFailed":
                return qsTr("Maker payment refund failed")
            default:
                return qsTr(event_name)
        }
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:1200}
}
##^##*/
