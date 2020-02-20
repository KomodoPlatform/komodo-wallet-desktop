import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_trade

    property string prev_base
    property string prev_rel

    function open(ticker) {
        setTicker(combo_base, ticker)
    }

    function getCoins() {
        return API.get().enabled_coins
    }

    function getTicker(is_base) {
        return is_base ? form_base.getTicker() : form_rel.getTicker()
    }

    function setTicker(is_base, ticker) {
        if(is_base) form_base.setTicker(ticker)
        else form_rel.setTicker(ticker)
    }

    function swapPair() {
        let base = getTicker(true)
        let rel = getTicker(false)

        // Fill previous ones if they are blank
        if(prev_base === '') prev_base = getCoins().filter(c => c.ticker !== rel)[0].ticker
        if(prev_rel === '') prev_rel = getCoins().filter(c => c.ticker !== base)[0].ticker

        // Get different value if they are same
        if(base === rel) {
            if(base !== prev_base) base = prev_base
            else if(rel !== prev_rel) rel = prev_rel
        }

        // Swap
        const curr_base = base
        setTicker(true, rel)
        setTicker(false, curr_base)
    }

    function validBaseRel() {
        const base = getTicker(true)
        const rel = getTicker(false)
        return base !== '' && rel !== '' && base !== rel
    }

    function reset() {
        form_base.reset()
        form_rel.reset()
    }

    function setPair() {
        const base = getTicker(true)
        const rel = getTicker(false)

        if(base === rel) swapPair()
        else {
            if(validBaseRel()) {
                reset()
                API.get().set_current_orderbook(base)
                //orderbook.updateOrderbook()

                exchange.onTradeTickerChanged(base)
            }
        }
    }

    function trade(base, rel, base_volume, rel_volume) {
        action_result = API.get().trade(base, rel, base_volume, rel_volume) ? "success" : "error"
        if(action_result === "success") {
            reset()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 15

        // Sell
        OrderForm {
            id: form_base
            Layout.fillWidth: true
            my_side: true
        }

        // Receive
        OrderForm {
            Layout.fillWidth: true
            id: form_rel
        }

        // Trade button
        Button {
            id: action_button
            Layout.fillWidth: true

            text: qsTr("Trade")
            enabled: form_base.isValid() && form_rel.isValid()
            onClicked: tradeCoin(getTicker(true), getTicker(false), form_base.field.text, form_rel.field.text)
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
