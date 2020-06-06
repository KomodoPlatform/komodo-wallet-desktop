import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"
import "./Trade"
import "./Orders"
import "./History"

Item {
    id: exchange
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

        spacing: 20

        // Top tabs
        RowLayout {
            id: tabs
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.topMargin: 30
            spacing: 40

            ExchangeTab {
                dashboard_index: General.idx_exchange_trade
                text: API.get().empty_string + (qsTr("Trade"))
            }

            ExchangeTab {
                dashboard_index: General.idx_exchange_orders
                text: API.get().empty_string + (qsTr("Orders"))
            }

            ExchangeTab {
                dashboard_index: General.idx_exchange_history
                text: API.get().empty_string + (qsTr("History"))
            }
        }

        HorizontalLine {
            width: tabs.width * 1.25
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        // Bottom content
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: 15
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
               if(swap.error_events.indexOf(e.state) !== -1) {
                   return e
               }
            }
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
