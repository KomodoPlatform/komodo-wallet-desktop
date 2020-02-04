pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property int minimumWidth: 1280
    readonly property int minimumHeight: 600
    readonly property string assets_path: Qt.resolvedUrl(".") + "../../assets/"
    readonly property string image_path: assets_path + "images/"
    readonly property string coin_icons_path: image_path + "coins/"
    function coinIcon(ticker) {
        return ticker === "" ? "" : coin_icons_path + ticker.toLowerCase() + ".png"
    }

    readonly property int idx_dashboard_wallet: 0
    readonly property int idx_dashboard_exchange: 1
    readonly property int idx_dashboard_news: 2
    readonly property int idx_dashboard_dapps: 3
    readonly property int idx_dashboard_settings: 4

    readonly property int idx_exchange_trade: 0
    readonly property int idx_exchange_orders: 1
    readonly property int idx_exchange_history: 2

    function diffPrefix(received) {
        return received === "" ? "" : received === true ? "+ " :  "- "
    }

    function filterCoins(list, text) {
        return list.filter(c => c.ticker.indexOf(text.toUpperCase()) !== -1 || c.name.toUpperCase().indexOf(text.toUpperCase()) !== -1)
    }

    function formatFiat(received, amount, fiat) {
        const symbols = {
            "USD": "$",
            "EUR": "€"
        }

        return diffPrefix(received) + symbols[fiat] + amount
    }

    function formatCrypto(received, amount, ticker, fiat_amount, fiat) {
        return diffPrefix(received) + amount + " " + ticker + (fiat_amount ? " (" + formatFiat("", fiat_amount, fiat) + ")" : "")
    }
}
