pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property int minimumWidth: 1280
    readonly property int minimumHeight: 800
    readonly property string assets_path: Qt.resolvedUrl(".") + "../../assets/"
    readonly property string image_path: assets_path + "images/"
    readonly property string coin_icons_path: image_path + "coins/"
    function coinIcon(ticker) {
        return ticker === "" ? "" : coin_icons_path + ticker.toLowerCase() + ".png"
    }

    property bool privacy_mode: false

    readonly property int idx_dashboard_portfolio: 0
    readonly property int idx_dashboard_wallet: 1
    readonly property int idx_dashboard_exchange: 2
    readonly property int idx_dashboard_news: 3
    readonly property int idx_dashboard_dapps: 4
    readonly property int idx_dashboard_settings: 5
    readonly property int idx_dashboard_light_ui: 6
    readonly property int idx_dashboard_privacy_mode: 7

    readonly property int idx_exchange_trade: 0
    readonly property int idx_exchange_orders: 1
    readonly property int idx_exchange_history: 2

    readonly property var reg_pass_input: /[A-Za-z0-9@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]+/
    readonly property var reg_pass_valid: /^(?=.{16,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]).*$/
    readonly property var reg_pass_uppercase: /(?=.*[A-Z])/
    readonly property var reg_pass_lowercase: /(?=.*[a-z])/
    readonly property var reg_pass_numeric: /(?=.*[0-9])/
    readonly property var reg_pass_special: /(?=.*[@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?])/
    readonly property var reg_pass_count: /(?=.{16,})/
    
    readonly property double time_toast_important_error: 10000
    readonly property double time_toast_basic_info: 3000

    readonly property var chart_times: (["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "12h", "1d", "3d", "1w"])
    readonly property var time_seconds: ({ "1m": 60, "3m": 180, "5m": 300, "15m": 900, "30m": 1800, "1h": 3600, "2h": 7200, "4h": 14400, "6h": 21600, "12h": 43200, "1d": 86400, "3d": 259200, "1w": 604800 })

    function timestampToDouble(timestamp) {
        return (new Date(timestamp)).getTime()
    }

    function timestampToString(timestamp) {
        return (new Date(timestamp)).getUTCDate()
    }

    function timestampToDate(timestamp) {
        return (new Date(timestamp * 1000))
    }
    
    function clone(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    function prettifyJSON(j) {
        return JSON.stringify(JSON.parse(j), null, 4)
    }

    function viewTxAtExplorer(ticker, id, add_0x=false) {
        if(id !== '') {
            const coin_info = API.get().get_coin_info(ticker)
            const id_prefix = add_0x && coin_info.type === 'ERC-20' ? '0x' : ''
            Qt.openUrlExternally(coin_info.explorer_url + 'tx/' + id_prefix + id)
        }
    }

    function diffPrefix(received) {
        return received === "" ? "" : received === true ? "+ " :  "- "
    }

    function filterCoins(list, text, type) {
        return list.filter(c => (c.ticker.indexOf(text.toUpperCase()) !== -1 || c.name.toUpperCase().indexOf(text.toUpperCase()) !== -1) &&
                           (type === undefined || c.type === type))
    }

    function getCoin(list, ticker) {
        return list.find(c => c.ticker === ticker)
    }

    function formatFiat(received, amount, fiat) {
        const symbols = {
            "USD": "$",
            "EUR": "€"
        }

        return diffPrefix(received) + symbols[fiat] + " " + amount
    }

    function formatPercent(value, show_prefix=true) {
        let prefix = ''
        if(value > 0) prefix = '+ '
        else if(value < 0) {
            prefix = '- '
            value *= -1
        }

        return (show_prefix ? prefix : '') + value + ' %'
    }

    readonly property int amountPrecision: 8
    readonly property int sliderDigitLimit: 9
    
    function formatDouble(v, precision) {
        if(precision === 0) return parseInt(v).toString()
        // Remove more than n decimals, then convert to string without trailing zeros
        return parseFloat(v).toFixed(precision || amountPrecision).replace(/\.?0+$/,"")
    }

    function formatCrypto(received, amount, ticker, fiat_amount, fiat) {
        return diffPrefix(received) + formatDouble(amount) + " " + ticker + (fiat_amount ? " (" + formatFiat("", fiat_amount, fiat) + ")" : "")
    }

    function fullCoinName(name, ticker) {
        return name + " (" + ticker + ")"
    }

    function fullNamesOfCoins(coins) {
        return coins.map(c => fullCoinName(c.name, c.ticker))
    }

    function getTickers(coins) {
        return coins.map(c => c.ticker)
    }


    function tickerAndBalance(ticker) {
        return ticker + " (" + API.get().get_balance(ticker) + ")"
    }

    function getTickersAndBalances(coins) {
        return coins.map(c => c.ticker + " (" + c.balance + ")")
    }

    function getMinTradeAmount() {
        return 0.00777
    }

    function hasEnoughFunds(sell, base, rel, price, volume) {
        if(sell) {
            if(volume === "") return true
            return API.get().do_i_have_enough_funds(base, volume)
        }
        else {
            if(price === "") return true
            const needed_amount = parseFloat(price) * parseFloat(volume)
            return API.get().do_i_have_enough_funds(rel, needed_amount)
        }
    }

    function isZero(v) {
        return parseFloat(v) === 0
    }

    function fieldExists(v) {
        return v !== undefined && v !== ""
    }

    function getField(o, field, def) {
        return o === undefined ? def : o[field]
    }

    function filterRecentSwaps(all_orders, finished_option, ticker) {
        let orders = all_orders

        Object.keys(orders).map((key, index) => {
          orders[key].uuid = key
          orders[key].is_recent_swap = true
          orders[key].am_i_maker = orders[key].type.toLowerCase() === 'maker'
        })

        let arr = Object.values(orders).sort((a, b) => b.events[b.events.length-1].timestamp - a.events[a.events.length-1].timestamp)

        // Filter by finished
        if(finished_option !== undefined && finished_option !== "")
            arr = arr.filter(o => {
                for(let e of o.events) {
                    if(e.state === "Finished")
                        return finished_option === "include"
                }

                return finished_option === "exclude"
            })

        // Filter by ticker
        if(ticker)
            arr = arr.filter(o => o.my_info.my_coin === ticker || o.my_info.other_coin === ticker)

        return arr
    }

    function formatOrder(o) {
        if(o.is_recent_swap) {
            o.date = o.events[o.events.length-1].human_timestamp
        }
        else {
            o.my_info = {
                my_coin: o.base,
                my_amount: o.base_amount,
                other_coin: o.rel,
                other_amount: o.rel_amount
            }
        }
        return o
    }

    function isEthNeeded() {
        for(const c of API.get().enabled_coins)
            if(c.type === "ERC-20" && c.ticker !== "ETH") return true

        return false
    }

    function canDisable(ticker) {
        if(API.get().enabled_coins.length <= 2) return false
        if(ticker === "ETH") return !General.isEthNeeded()

        return true
    }

    function isEthEnabled() {
        for(const c of API.get().enabled_coins)
            if(c.ticker === "ETH") return true

        return false
    }

    function enableEthIfNeeded() {
        if(!isEthEnabled() && isEthNeeded()) {
            API.get().enable_coins(["ETH"])
            return true
        }

        return false
    }

    function getRandomInt(min, max) {
        min = Math.ceil(min)
        max = Math.floor(max)
        return Math.floor(Math.random() * (max - min + 1)) + min
    }
}
