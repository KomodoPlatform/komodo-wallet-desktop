import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_trade

    function changeBase(ticker) {
        combo_base.currentIndex = baseCoins().map(c => c.ticker).indexOf(ticker)
        base = ticker
    }

    function swapPair() {
        const curr_base = base
        changeBase(rel)
        combo_rel.currentIndex = relCoins().map(c => c.ticker).indexOf(curr_base)
    }

    function validBaseRel() {
        return base && rel && base !== "" && rel !== "" && base !== rel
    }

    function setPair() {
        console.log("SET PAIR: " + base + " - " + rel)
        if(validBaseRel()) {
            API.get().set_current_orderbook(base, rel)
            orderbook.updateOrderbook()
        }
    }

    function reset() {
        order_form_sell.reset()
        order_form_buy.reset()
    }

    function baseCoins() {
        return API.get().enabled_coins
    }

    function relCoins() {
        return API.get().enabled_coins.filter(c => c.ticker !== base)
    }

    property string base
    property string rel

    onBaseChanged: setPair()
    onRelChanged: setPair()

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
                    source: General.coinIcon(base)
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                ComboBox {
                    id: combo_base
                    Layout.preferredWidth: 250
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10

                    model: General.fullNamesOfCoins(baseCoins())
                    onCurrentTextChanged: {
                        base = baseCoins()[currentIndex].ticker
                        reset()
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

                    model: General.fullNamesOfCoins(relCoins())
                    onCurrentTextChanged: rel = relCoins()[currentIndex].ticker
                }

                Image {
                    Layout.rightMargin: 15
                    source: General.coinIcon(rel)
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
                    base: exchange_trade.base
                    rel: exchange_trade.rel

                    visible: false
                }

                // Sell
                OrderForm {
                    id: order_form_sell
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    sell: true
                    base: exchange_trade.base
                    rel: exchange_trade.rel
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
