import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

Item {
    id: exchange_trade

    height: 500

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

        width: 1000
        spacing: 20

        // Select coins row
        RowLayout {
            Layout.fillWidth: true
            // Base
            ComboBox {
                id: combo_base
                Layout.preferredWidth: 250
                model: convertToFullName(baseCoins())
                onCurrentTextChanged: base = baseCoins()[currentIndex].ticker
            }

            Image {
                source: General.image_path + "exchange-exchange.svg"
            }

            // Rel Base
            ComboBox {
                id: combo_rel
                Layout.preferredWidth: 250
                model: convertToFullName(relCoins())
                onCurrentTextChanged: rel = relCoins()[currentIndex].ticker
            }
        }

        DefaultText {
            text: "Base: " + base
        }

        DefaultText {
            text: "Rel: " + rel
        }
    }
}









