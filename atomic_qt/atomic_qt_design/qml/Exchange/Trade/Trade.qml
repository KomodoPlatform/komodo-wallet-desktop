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
    }

    function reset() {
        order_form_sell.reset()
        order_form_buy.reset()
    }

    function convertToFullName(coins) {
        return coins.map(c => c.name + " (" + c.ticker + ")")
    }

    function baseCoins() {
        return API.get().enabled_coins
    }

    function relCoins() {
        return API.get().enabled_coins.filter(c => c.ticker !== base)
    }

    property string base
    property string rel

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
                    source: base === "" ? base : General.coin_icons_path + base + ".png"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                ComboBox {
                    id: combo_base
                    Layout.preferredWidth: 250
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10

                    model: convertToFullName(baseCoins())
                    onCurrentTextChanged: {
                        base = baseCoins()[currentIndex].ticker
                        reset()
                    }
                }

                Image {
                    source: General.image_path + "exchange-exchange.svg"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: changeBase(rel)
                    }
                }

                // Rel Base
                ComboBox {
                    id: combo_rel
                    Layout.preferredWidth: 250

                    model: convertToFullName(relCoins())
                    onCurrentTextChanged: rel = relCoins()[currentIndex].ticker
                }

                Image {
                    Layout.rightMargin: 15
                    source: base === "" ? base : General.coin_icons_path + rel + ".png"
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
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
