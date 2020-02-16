import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_trade

    function changeBase(ticker) {
    property string prev_base
    property string prev_rel

    function open(ticker) {
        setTicker(combo_base, ticker)
    }

    function getCoins() {
        return API.get().enabled_coins
    }

    function getTicker(combo) {
        if(combo.currentIndex === -1) return ''

        return getCoins()[combo.currentIndex].ticker
    }

    function setTicker(combo, ticker) {
        combo.currentIndex = getCoins().map(c => c.ticker).indexOf(ticker)
    }

    function swapPair() {
        let base = getTicker(combo_base)
        let rel = getTicker(combo_rel)

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
        setTicker(combo_base, rel)
        setTicker(combo_rel, curr_base)
    }

    function validBaseRel() {
        const base = getTicker(combo_base)
        const rel = getTicker(combo_rel)
        return base !== '' && rel !== '' && base !== rel
    }

    function reset() {
        order_form_sell.reset()
        order_form_buy.reset()
    }

    function setPair() {
        const base = getTicker(combo_base)
        const rel = getTicker(combo_rel)

        if(base === rel) swapPair()
        else {
            if(validBaseRel()) {
                reset()
                API.get().set_current_orderbook(base, rel)
                orderbook.updateOrderbook()
            }
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.height
        spacing: 15

        // Select coins row
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height

            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius

            RowLayout {
                // Base
                Image {
                    Layout.leftMargin: 15
                    source: General.coinIcon(getTicker(combo_base))
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                ComboBox {
                    id: combo_base
                    Layout.preferredWidth: 250
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10

                    model: General.fullNamesOfCoins(getCoins())
                    onCurrentTextChanged: {
                        setPair()
                        prev_base = getTicker(combo_base)
                    }
                }

                Image {
                    source: General.image_path + "exchange-exchange.svg"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: swapPair()
                    }
                }

                // Rel
                ComboBox {
                    id: combo_rel
                    Layout.preferredWidth: 250

                    model: General.fullNamesOfCoins(getCoins())
                    onCurrentTextChanged: {
                        setPair()
                        prev_rel = getTicker(combo_rel)
                    }
                }

                Image {
                    Layout.rightMargin: 15
                    source: General.coinIcon(getTicker(combo_rel))
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }
            }
        }

        // Bottom part
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: parent.spacing

            // Left side
            ColumnLayout {
                spacing: parent.spacing
                Layout.minimumWidth: 300
                Layout.maximumWidth: Layout.minimumWidth

                // Buy
                OrderForm {
                    id: order_form_buy
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    sell: false
                    base: getTicker(combo_base)
                    rel: getTicker(combo_rel)

                    visible: false
                }

                // Sell
                OrderForm {
                    id: order_form_sell
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    sell: true
                    base: getTicker(combo_base)
                    rel: getTicker(combo_rel)
                }
            }

            // Right side
            Orderbook {
                id: orderbook
                Layout.fillWidth: true
                Layout.fillHeight: true
                timer.running: validBaseRel()
            }
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
