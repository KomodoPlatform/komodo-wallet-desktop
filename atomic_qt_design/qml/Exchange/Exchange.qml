import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"
import "./Trade"
import "./Orders"
import "./History"

Item {
    id: exchange
    readonly property int layout_margin: 30
    property int current_page: API.design_editor ? General.idx_exchange_trade : General.idx_exchange_trade

    function reset() {
        current_page = General.idx_exchange_trade
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
        if(current_page === General.idx_exchange_trade) {
            exchange_trade.onOpened()
        }
        else if(current_page === General.idx_exchange_orders) {
            exchange_orders.onOpened()
        }
        else if(current_page === General.idx_exchange_history) {
            exchange_history.onOpened()
        }
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
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin

            content: Item {
                id: content
                width: balance_box.width
                height: 62

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 30

                    ExchangeTab {
                        dashboard_index: General.idx_exchange_trade
                        text_value: API.get().empty_string + (qsTr("Trade"))
                    }

                    VerticalLineBasic {
                        id: vline
                        height: content.height * 0.5
                        color: Style.colorTheme5
                    }

                    ExchangeTab {
                        dashboard_index: General.idx_exchange_orders
                        text_value: API.get().empty_string + (qsTr("Orders"))
                    }

                    VerticalLineBasic {
                        height: vline.height
                        color: vline.color
                    }

                    ExchangeTab {
                        dashboard_index: General.idx_exchange_history
                        text_value: API.get().empty_string + (qsTr("History"))
                    }
                }
            }
        }

        // Bottom content
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: layout_margin
            Layout.leftMargin: Layout.bottomMargin
            Layout.rightMargin: Layout.bottomMargin

            currentIndex: current_page

            Trade {
                id: exchange_trade

                onOrderSuccess: () => {
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



    // Status Info
    readonly property int status_swap_not_swap: -1
    readonly property int status_swap_matching: 0
    readonly property int status_swap_matched: 1
    readonly property int status_swap_ongoing: 2
    readonly property int status_swap_successful: 3
    readonly property int status_swap_failed: 4

    function getSwapError(swap) {
        if(swap.is_recent_swap) {
            for(let i = swap.events.length - 1; i > 0; --i) {
                const e = swap.events[i]
               if(e.data && e.data.error && swap.error_events.indexOf(e.state) !== -1) {
                   return e
               }
            }
        }

        return { state: '', data: { error: '' } }
    }

    function getLastEvent(swap) {
        if(swap.is_recent_swap && swap.events.length > 0) {
            return swap.events[swap.events.length-1]
        }

        return { state: '', data: { error: '' } }
    }

    function getStatus(swap) {
        if(!swap.is_recent_swap && !swap.am_i_maker) return status_swap_matching
        if(!swap.is_recent_swap) return status_swap_not_swap

        const last_state = swap.events[swap.events.length-1].state

        if(last_state === "Started") return status_swap_matched
        if(last_state === "Finished") return getSwapError(swap).state === '' ? status_swap_successful : status_swap_failed

        return status_swap_ongoing
    }

    function getStatusColor(swap) {
        const status = getStatus(swap)
        return status === status_swap_matching ? Style.colorYellow :
               status === status_swap_matched ? Style.colorOrange :
               status === status_swap_ongoing ? Style.colorOrange :
               status === status_swap_successful ? Style.colorGreen : Style.colorRed
    }

    function getStatusText(swap) {
        const status = getStatus(swap)
        return status === status_swap_matching ? qsTr("Order Matching") :
                status === status_swap_matched ? qsTr("Order Matched") :
                status === status_swap_ongoing ? qsTr("Swap Ongoing") :
                status === status_swap_successful ? qsTr("Swap Successful") :
                                                        qsTr("Swap Failed")
    }

    function getStatusStep(swap) {
        const status = getStatus(swap)
        return status === status_swap_matching ? "0/3":
               status === status_swap_matched ? "1/3":
               status === status_swap_ongoing ? "2/3":
               status === status_swap_successful ? Style.successCharacter : Style.failureCharacter
    }

    function getStatusTextWithPrefix(swap) {
        return getStatusStep(swap) + " " + getStatusText(swap)
    }

    function getSwapPaymentID(swap, is_taker) {
        if(swap.events !== undefined) {
            const search_name = swap.am_i_maker ?
                              (is_taker ? "TakerPaymentSpent" : "MakerPaymentSent") :
                              (is_taker ? "TakerPaymentSent" : "MakerPaymentSpent")
            for(const e of swap.events) {
               if(e.state === search_name) {
                   return e.data.tx_hash
               }
            }
        }

        return ''
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:1200}
}
##^##*/
