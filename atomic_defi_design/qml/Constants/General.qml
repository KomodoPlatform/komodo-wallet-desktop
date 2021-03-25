pragma Singleton
import QtQuick 2.15
import AtomicDEX.TradingError 1.0

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property int minimumWidth: 1280
    readonly property int minimumHeight: 800
    readonly property double delta_time: 1000/60

    readonly property string os_file_prefix: Qt.platform.os == "windows" ? "file:///" : "file://"
    readonly property string assets_path: "qrc:///"
    readonly property string image_path: assets_path + "atomic_defi_design/assets/images/"
    readonly property string coin_icons_path: image_path + "coins/"
    readonly property string custom_coin_icons_path: os_file_prefix + API.app.settings_pg.get_custom_coins_icons_path() + "/"

    function coinIcon(ticker) {
        if(ticker === "" || ticker === "All" || ticker===undefined) {
            return ""
        }else {
            const coin_info = API.app.portfolio_pg.global_cfg_mdl.get_coin_info(ticker)
            return (coin_info.is_custom_coin ? custom_coin_icons_path : coin_icons_path) + atomic_qt_utilities.retrieve_main_ticker(ticker.toString()).toLowerCase() + ".png"
        }
    }

    // Returns the icon full path of a coin type.
    // If the given coin type has spaces, it will be replaced by '-' characters.
    // If the given coin type is empty, returns an empty string.
    function coinTypeIcon(type) {
        if (type === "") return ""

        var filename = type.toLowerCase().replace(" ", "-");
        return coin_icons_path + filename + ".png"
    }

    function qaterialIcon(name) {
        return "qrc:/Qaterial/Icons/" + name + ".svg"
    }

    readonly property string cex_icon: 'ⓘ'
    readonly property string download_icon: '📥'
    readonly property string right_arrow_icon: "⮕"
    readonly property string privacy_text: "*****"

    readonly property string version_string: "Desktop v" + API.app.settings_pg.get_version()

    property bool privacy_mode: false

    readonly property var reg_pass_input: /[A-Za-z0-9@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]+/
    readonly property var reg_pass_valid_low_security: /^(?=.{1,}).*$/
    readonly property var reg_pass_valid: /^(?=.{16,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]).*$/
    readonly property var reg_pass_uppercase: /(?=.*[A-Z])/
    readonly property var reg_pass_lowercase: /(?=.*[a-z])/
    readonly property var reg_pass_numeric: /(?=.*[0-9])/
    readonly property var reg_pass_special: /(?=.*[@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?])/
    readonly property var reg_pass_count_low_security: /(?=.{1,})/
    readonly property var reg_pass_count: /(?=.{16,})/

    readonly property double time_toast_important_error: 10000
    readonly property double time_toast_basic_info: 3000

    readonly property var chart_times: (["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "12h", "1d", "3d"/*, "1w"*/])
    readonly property var time_seconds: ({ "1m": 60, "3m": 180, "5m": 300, "15m": 900, "30m": 1800, "1h": 3600, "2h": 7200, "4h": 14400, "6h": 21600, "12h": 43200, "1d": 86400, "3d": 259200, "1w": 604800 })


    property bool initialized_orderbook_pair: false
    readonly property string default_base: atomic_app_primary_coin
    readonly property string default_rel: atomic_app_secondary_coin

    function timestampToDouble(timestamp) {
        return (new Date(timestamp)).getTime()
    }

    function timestampToString(timestamp) {
        return (new Date(timestamp)).toUTCString()
    }

    function timestampToDate(timestamp) {
        return (new Date(timestamp * 1000))
    }

    function getDuration(total_ms) {
        let delta = Math.abs(total_ms)

        let days = Math.floor(delta / 86400000)
        delta -= days * 86400000

        let hours = Math.floor(delta / 3600000) % 24
        delta -= hours * 3600000

        let minutes = Math.floor(delta / 60000) % 60
        delta -= minutes * 60000

        let seconds = Math.floor(delta / 1000) % 60
        delta -= seconds * 1000

        let milliseconds = Math.floor(delta)

        return { days, hours, minutes, seconds, milliseconds }
    }

    function secondsToTimeLeft(date_now, date_future) {
        const r = getDuration((date_future - date_now)*1000)
        let days = r.days
        let hours = r.hours
        let minutes = r.minutes
        let seconds = r.seconds

        if(hours < 10) hours = '0' + hours
        if(minutes < 10) minutes = '0' + minutes
        if(seconds < 10) seconds = '0' + seconds
        return qsTr("%n day(s)", "", days) + '  ' + hours + ':' + minutes + ':' + seconds
    }

    function durationTextShort(total) {
        if(!General.exists(total))
            return "-"

        const r = getDuration(total)

        let text = ""
        if(r.days > 0) text += qsTr("%nd", "day", r.days) + "  "
        if(r.hours > 0) text += qsTr("%nh", "hours", r.hours) + "  "
        if(r.minutes > 0) text += qsTr("%nm", "minutes", r.minutes) + "  "
        if(r.seconds > 0) text += qsTr("%ns", "seconds", r.seconds) + "  "
        if(text === "" && r.milliseconds > 0) text += qsTr("%nms", "milliseconds", r.milliseconds) + "  "
        if(text === "") text += qsTr("-")

        return text
    }

    function absString(str) {
        return str.replace("-", "")
    }

    function clone(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    function prettifyJSON(j) {
        const j_obj = typeof j === "string" ? JSON.parse(j) : j
        return JSON.stringify(j_obj, null, 4)
    }

    function viewTxAtExplorer(ticker, id, add_0x=true) {
        if(id !== '') {
            const coin_info = API.app.portfolio_pg.global_cfg_mdl.get_coin_info(ticker)
            const id_prefix = add_0x && coin_info.type === 'ERC-20' || coin_info.type === 'BEP-20' ? '0x' : ''
            Qt.openUrlExternally(coin_info.explorer_url + coin_info.tx_uri + id_prefix + id)
        }
    }

    function viewAddressAtExplorer(ticker, address) {
        if(address !== '') {
            const coin_info = API.app.portfolio_pg.global_cfg_mdl.get_coin_info(ticker)
            Qt.openUrlExternally(coin_info.explorer_url + coin_info.address_uri + address)
        }
    }

    function diffPrefix(received) {
        return received === "" ? "" : received === true ? "+ " :  "- "
    }

    function filterCoins(list, text, type) {
        return list.filter(c => (c.ticker.indexOf(text.toUpperCase()) !== -1 || c.name.toUpperCase().indexOf(text.toUpperCase()) !== -1) &&
                           (type === undefined || c.type === type)).sort((a, b) => {
                               if(a.ticker < b.ticker) return -1
                               if(a.ticker > b.ticker) return 1
                               return 0
                           })
    }

    function validFiatRates(data, fiat) {
        return data && data.rates && data.rates[fiat]
    }

    function nFormatter(num, digits) {
      if(num < 1E5) return General.formatDouble(num)

      const si = [
        { value: 1, symbol: "" },
        { value: 1E3, symbol: "k" },
        { value: 1E6, symbol: "M" },
        { value: 1E9, symbol: "G" },
        { value: 1E12, symbol: "T" },
        { value: 1E15, symbol: "P" },
        { value: 1E18, symbol: "E" }
      ]
      const rx = /\.0+$|(\.[0-9]*[1-9])0+$/

      let i
      for (i = si.length - 1; i > 0; --i)
        if (num >= si[i].value) break

      return (num / si[i].value).toFixed(digits).replace(rx, "$1") + si[i].symbol
    }

    function formatFiat(received, amount, fiat) {
        return diffPrefix(received) +
                (fiat === API.app.settings_pg.current_fiat ? API.app.settings_pg.current_fiat_sign : API.app.settings_pg.current_currency_sign)
                + " " + nFormatter(parseFloat(amount), 2)
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
    readonly property int recommendedPrecision: -1337

    function getDigitCount(v) {
        return v.toString().replace("-", "").split(".")[0].length
    }

    function getRecommendedPrecision(v, limit) {
        const lim = limit || sliderDigitLimit
        return Math.min(Math.max(lim - getDigitCount(v), 0), amountPrecision)
    }

    function formatDouble(v, precision, trail_zeros) {
        if(v === '') return "0"
        if(precision === recommendedPrecision) precision = getRecommendedPrecision(v)

        if(precision === 0) return parseInt(v).toString()

        // Remove more than n decimals, then convert to string without trailing zeros
        const full_double = parseFloat(v).toFixed(precision || amountPrecision)

        return trail_zeros ? full_double : full_double.replace(/\.?0+$/,"")
    }

    function formatCrypto(received, amount, ticker, fiat_amount, fiat) {
        return diffPrefix(received) +  atomic_qt_utilities.retrieve_main_ticker(ticker) + " " + formatDouble(amount) + (fiat_amount ? " (" + formatFiat("", fiat_amount, fiat) + ")" : "")
    }

    function fullCoinName(name, ticker) {
        return name + " (" + ticker + ")"
    }

    function fullNamesOfCoins(coins) {
        return coins.map(c => {
         return { value: c.ticker, text: fullCoinName(c.name, c.ticker) }
        })
    }

    function tickersOfCoins(coins) {
        return coins.map(c => {
            return { value: c.ticker, text: c.ticker }
        })
    }

    function getMinTradeAmount() {
        return 0.00777
    }

    function hasEnoughFunds(sell, base, rel, price, volume) {
        if(sell) {
            if(volume === "") return true
            return API.app.do_i_have_enough_funds(base, volume)
        }
        else {
            if(price === "") return true
            const needed_amount = parseFloat(price) * parseFloat(volume)
            return API.app.do_i_have_enough_funds(rel, needed_amount)
        }
    }

    function isZero(v) {
        return !isFilled(v) || parseFloat(v) === 0
    }


    function exists(v) {
        return v !== undefined && v !== null
    }

    function isFilled(v) {
        return exists(v) && v !== ""
    }

    function isParentCoinNeeded(ticker, type) {
        for(const c of API.app.portfolio_pg.get_all_enabled_coins())
            if(c.type === type && c.ticker !== ticker) return true

        return false
    }

    property Timer prevent_coin_disabling: Timer { interval: 5000 }

    function canDisable(ticker) {
        if(prevent_coin_disabling.running)
            return false

        if(ticker === atomic_app_primary_coin || ticker === atomic_app_secondary_coin) return false
        else if(ticker === "ETH") return !General.isParentCoinNeeded("ETH", "ERC-20")
        else if(ticker === "QTUM") return !General.isParentCoinNeeded("QTUM", "QRC-20")

        return true
    }

    function tokenUnitName(type) {
        return type === "ERC-20" ? "Gwei" : "Satoshi"
    }

    function isParentCoin(ticker) {
        return ticker === "KMD" || ticker === "ETH" || ticker === "QTUM"
    }

    function isTokenType(type) {
        return type === "ERC-20" || type === "QRC-20"
    }

    function getParentCoin(type) {
        if(type === "ERC-20") return "ETH"
        else if(type === "QRC-20") return "QTUM"
        else if(type === "Smart Chain") return "KMD"
        return "?"
    }

    function getRandomInt(min, max) {
        min = Math.ceil(min)
        max = Math.floor(max)
        return Math.floor(Math.random() * (max - min + 1)) + min
    }

    function getFiatText(v, ticker, has_info_icon=true) {
        return General.formatFiat('', v === '' ? 0 : API.app.get_fiat_from_amount(ticker, v), API.app.settings_pg.current_fiat)
                + (has_info_icon ? " " +  General.cex_icon : "")
    }

    function hasParentCoinFees(trade_info) {
        return General.isFilled(trade_info.rel_transaction_fees) && parseFloat(trade_info.rel_transaction_fees) > 0
    }

    function feeText(trade_info, base_ticker, has_info_icon=true, has_limited_space=false) {


        if(!trade_info || !trade_info.trading_fee) return ""

        const tx_fee = txFeeText(trade_info, base_ticker, has_info_icon, has_limited_space)
        const trading_fee = tradingFeeText(trade_info, base_ticker, has_info_icon)
        const minimum_amount = minimumtradingFeeText(trade_info, base_ticker, has_info_icon)


        return tx_fee + "\n" + trading_fee +"<br>"+minimum_amount
    }

    function txFeeText(trade_info, base_ticker, has_info_icon=true, has_limited_space=false) {

        if(!trade_info || !trade_info.trading_fee) return ""

        const has_parent_coin_fees = hasParentCoinFees(trade_info)

         var info =  qsTr('%1 Transaction Fee'.arg(trade_info.base_transaction_fees_ticker))+': '+ trade_info.base_transaction_fees + " (%1)".arg(getFiatText(trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker, has_info_icon))

        if (has_parent_coin_fees) {
            info = info+"<br>"+qsTr('%1 Transaction Fee'.arg(trade_info.rel_transaction_fees_ticker))+': '+ trade_info.rel_transaction_fees + " (%1)".arg(getFiatText(trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker, has_info_icon))
        }

        return info+"<br>"
//        const main_fee = (qsTr('Transaction Fee') + ': ' + General.formatCrypto("", trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker)) +
//                                 // Rel Fees
//                                 (has_parent_coin_fees ? " + " + General.formatCrypto("", trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker) : '')

//        let fiat_part = "("
//        fiat_part += getFiatText(trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker, false)
//        if(has_parent_coin_fees) fiat_part += (has_limited_space ? "\n\t\t+ " : " + ") + getFiatText(trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker, has_info_icon)
//        fiat_part += ")"

//        return main_fee + " " + fiat_part
    }
//    function txFeeText2(trade_info, base_ticker, has_info_icon=true, has_limited_space=false) {
//        if(!trade_info || !trade_info.trading_fee) return ""

//        const has_parent_coin_fees = hasParentCoinFees(trade_info)
//        const main_fee = (qsTr('Transaction Fee') + ': ' + General.formatCrypto("", trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker)) +
//                                 // Rel Fees
//                                 (has_parent_coin_fees ? " + " + General.formatCrypto("", trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker) : '')

//        let fiat_part = "("
//        fiat_part += getFiatText(trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker, false)
//        if(has_parent_coin_fees) fiat_part += (has_limited_space ? "\n\t\t+ " : " + ") + getFiatText(trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker, has_info_icon)
//        fiat_part += ")"

//        return main_fee + " " + fiat_part
//    }

    function tradingFeeText(trade_info, base_ticker, has_info_icon=true) {
        if(!trade_info || !trade_info.trading_fee) return ""

        return trade_info.trading_fee_ticker+" "+qsTr('Trading Fee') + ': ' + General.formatCrypto("", trade_info.trading_fee, "") +

                // Fiat part
                (" ("+
                    getFiatText(trade_info.trading_fee, trade_info.trading_fee_ticker, has_info_icon)
                 +")")
    }
    function minimumtradingFeeText(trade_info, base_ticker, has_info_icon=true) {
        if(!trade_info || !trade_info.trading_fee) return ""

        return API.app.trading_pg.market_pairs_mdl.left_selected_coin+" "+qsTr('Minimum Trading Amount') + ': ' + General.formatCrypto("", API.app.trading_pg.min_trade_vol , "") +

                // Fiat part
                (" ("+
                    getFiatText(API.app.trading_pg.min_trade_vol , API.app.trading_pg.market_pairs_mdl.left_selected_coin, has_info_icon)
                 +")")
    }

    function checkIfWalletExists(name) {
        if(API.app.wallet_mgr.get_wallets().indexOf(name) !== -1)
            return qsTr("Wallet %1 already exists", "WALLETNAME").arg(name)
        return ""
    }

    function getTradingError(error, fee_info, base_ticker, rel_ticker) {
        switch(error) {
        case TradingError.None:
            return ""
        case TradingError.TradingFeesNotEnoughFunds:
            return qsTr("Not enough balance for trading fees: %1", "AMT TICKER").arg(General.formatCrypto("", fee_info.trading_fee, fee_info.trading_fee_ticker))
        case TradingError.TotalFeesNotEnoughFunds:
            return qsTr("Not enough balance for total fees")
        case TradingError.BaseTransactionFeesNotEnough:
            return qsTr("Not enough balance for transaction fees: %1", "AMT TICKER").arg(General.formatCrypto("", fee_info.base_transaction_fees, fee_info.base_transaction_fees_ticker))
        case TradingError.RelTransactionFeesNotEnough:
            return qsTr("Not enough balance for transaction fees: %1", "AMT TICKER").arg(General.formatCrypto("", fee_info.rel_transaction_fees, fee_info.rel_transaction_fees_ticker))
        case TradingError.BalanceIsLessThanTheMinimalTradingAmount:
            return qsTr("Tradable (after fees) %1 balance is lower than minimum trade amount").arg(base_ticker) + " : " + General.getMinTradeAmount()
        case TradingError.PriceFieldNotFilled:
            return qsTr("Please fill the price field")
        case TradingError.VolumeFieldNotFilled:
            return qsTr("Please fill the volume field")
        case TradingError.VolumeIsLowerThanTheMinimum:
            return qsTr("%1 volume is lower than minimum trade amount").arg(base_ticker) + " : " + General.getMinTradeAmount()
        case TradingError.ReceiveVolumeIsLowerThanTheMinimum:
            return qsTr("%1 volume is lower than minimum trade amount").arg(rel_ticker) + " : " + General.getMinTradeAmount()
        default:
            return qsTr("Unknown Error") + ": " + error
        }
    }

    readonly property var supported_pairs: ({
                                                "1INCH/BTC": "BINANCE:1INCHBTC",
                                                "1INCH/ETH": "HUOBI:1INCHETH",
                                                "1INCH/USDT": "BINANCE:1INCHUSDT",
                                                "1INCH/BUSD": "BINANCE:1INCHBUSD",
                                                "AAVE/BTC": "BINANCE:AAVEBTC",
                                                "AAVE/ETH": "BINANCE:AAVEETH",
                                                "AAVE/BNB": "BINANCE:AAVEBNB",
                                                "AAVE/USDT": "BINANCE:AAVEUSDT",
                                                "AAVE/BUSD": "BINANCE:AAVEBUSD",
                                                "AGI/BTC": "BINANCE:AGIBTC",
                                                "AGI/ETH": "KUCOIN:AGIETH",
                                                "ANT/BTC": "BINANCE:ANTBTC",
                                                "ANT/ETH": "BITFINEX:ANTETH",
                                                "ANT/BNB": "BINANCE:ANTBNB",
                                                "ANT/USDT": "BINANCE:ANTUSDT",
                                                "ANT/BUSD": "BINANCE:ANTBUSD",
                                                "ARPA/BTC": "BINANCE:ARPABTC",
                                                "ARPA/USDT": "BINANCE:ARPAUSDT",
                                                "ARPA/BNB": "BINANCE:ARPABNB",
                                                "ARPA/HT": "HUOBI:ARPAHT",
                                                "BAL/BTC": "BINANCE:BALBTC",
                                                "BAL/ETH": "HUOBI:BALETH",
                                                "BAL/USDT": "BINANCE:BALUSDT",
                                                "BAL/BUSD": "BINANCE:BALBUSD",
                                                "BAL/HUSD": "HUOBI:BALHUSD",
                                                "BAND/BTC": "BINANCE:BANDBTC",
                                                "BAND/ETH": "HUOBI:BANDETH",
                                                "BAND/BNB": "BINANCE:BANDBNB",
                                                "BAND/USDT": "BINANCE:BANDUSDT",
                                                "BAND/BUSD": "BINANCE:BANDBUSD",
                                                "BAND/HUSD": "HUOBI:BANDHUSD",
                                                "BAT/USDT": "BINANCE:BATUSDT",
                                                "BAT/BUSD": "BINANCE:BATBUSD",
                                                "BAT/USDC": "BINANCE:BATUSDC",
                                                "BAT/BTC": "BINANCE:BATBTC",
                                                "BAT/ETH": "BITTREX:BATETH",
                                                "BAT/BNB": "BINANCE:BATBNB",
                                                "BEST/BTC": "BITPANDAPRO:BESTBTC",
                                                "BEST/USDT": "BITTREX:BESTUSDT",
                                                "BCH/BTC": "BINANCE:BCHBTC",
                                                "BCH/ETH": "BITTREX:BCHETH",
                                                "BCH/BNB": "BINANCE:BCHBNB",
                                                "BCH/USDT": "BINANCE:BCHUSDT",
                                                "BCH/BUSD": "BINANCE:BCHBUSD",
                                                "BCH/EURS": "HITBTC:BCHEURS",
                                                "BCH/HUSD": "HUOBI:BCHHUSD",
                                                "BCH/USDC": "BINANCE:BCHUSDC",
                                                "BCH/PAX": "BINANCE:BCHPAX",
                                                "BCH/TUSD": "BINANCE:BCHTUSD",
                                                "BCH/DAI": "HITBTC:BCHDAI",
                                                "BLK/BTC": "BITTREX:BLKBTC",
                                                "BNB/BTC": "BINANCE:BNBBTC",
                                                "BNB/ETH": "BINANCE:BNBETH",
                                                "BNB/USDT": "BINANCE:BNBUSDT",
                                                "BNB/BUSD": "BINANCE:BNBBUSD",
                                                "BNB/DAI": "BINANCE:BNBDAI",
                                                "BNB/PAX": "BINANCE:BNBPAX",
                                                "BNB/TUSD": "BINANCE:BNBTUSD",
                                                "BNB/USDC": "BINANCE:BNBUSDC",
                                                "BNT/BTC": "BINANCE:BNTBTC",
                                                "BNT/USDT": "BINANCE:BNTUSDT",
                                                "BNT/BUSD": "BINANCE:BNTBUSD",
                                                "BNT/ETH": "BINANCE:BNTETH",
                                                "BTC/USDT": "BINANCE:BTCUSDT",
                                                "BTC/BUSD": "BINANCE:BTCBUSD",
                                                "BTC/DAI": "BINANCE:BTCDAI",
                                                "BTC/EURS": "HITBTC:BTCEURS",
                                                "BTC/EUR": "BINANCE:BTCEUR",
                                                "BTC/HUSD": "HUOBI:BTCHUSD",
                                                "BTC/PAX": "BINANCE:BTCPAX",
                                                "BTC/TUSD": "BINANCE:BTCTUSD",
                                                "BTC/USDC": "BINANCE:BTCUSDC",
                                                "BTU/BTC": "BITTREX:BTUBTC",
                                                "CEL/BTC": "HITBTC:CELBTC",
                                                "CEL/ETH": "HITBTC:CELETH",
                                                "CEL/USDT": "BITTREX:CELUSDT",
                                                "CENNZ/BTC": "HITBTC:CENNZBTC",
                                                "CENNZ/ETH": "HITBTC:CENNZETH",
                                                "CENNZ/USDT": "HITBTC:CENNZUSDT",
                                                "CHSB/BTC": "KUCOIN:CHSBBTC",
                                                "CHSB/ETH": "KUCOIN:CHSBETH",
                                                "CHZ/BTC": "BINANCE:CHZBTC",
                                                "CHZ/ETH": "HUOBI:CHZETH",
                                                "CHZ/USDT": "BINANCE:CHZUSDT",
                                                "CHZ/BUSD": "BINANCE:CHZBUSD",
                                                "COMP/BTC": "BINANCE:COMPBTC",
                                                "COMP/ETH": "KRAKEN:COMPETH",
                                                "COMP/USDT": "BINANCE:COMPUSDT",
                                                "COMP/BUSD": "BINANCE:COMPBUSD",
                                                "CRO/BTC": "BITTREX:CROBTC",
                                                "CRO/ETH": "BITTREX:CROETH",
                                                "CRO/USDT": "OKEX:CROUSDT",
                                                "CRV/BTC": "BINANCE:CRVBTC",
                                                "CRV/ETH": "KRAKEN:CRVETH",
                                                "CRV/USDT": "BINANCE:CRVUSDT",
                                                "CRV/BUSD": "BINANCE:CRVBUSD",
                                                "CRV/HUSD": "HUOBI:CRVHUSD",
                                                "CVC/BTC": "BINANCE:CVCBTC",
                                                "CVC/ETH": "BINANCE:CVCETH",
                                                "CVC/USDT": "BINANCE:CVCUSDT",
                                                "CVC/USDC": "COINBASE:CVCUSDC",
                                                "CVT/BTC": "BITTREX:CVTBTC",
                                                "CVT/ETH": "HITBTC:CVTETH",
                                                "CVT/USDT": "OKEX:CVTUSDT",
                                                "DASH/USDT": "BINANCE:DASHUSDT",
                                                "DASH/BUSD": "BINANCE:DASHBUSD",
                                                "DASH/ETH": "BINANCE:DASHETH",
                                                "DASH/BTC": "BINANCE:DASHBTC",
                                                "DASH/BCH": "HITBTC:DASHBCH",
                                                "DASH/BNB": "BINANCE:DASHBNB",
                                                "DASH/EURS": "HITBTC:DASHEURS",
                                                "DASH/HUSD": "HUOBI:DASHHUSD",
                                                "DASH/USDC": "POLONIEX:DASHUSDC",
                                                "DASH/HT": "HUOBI:DASHHT",
                                                "DOGE/BTC": "BINANCE:DOGEBTC",
                                                "DOGE/ETH": "HITBTC:DOGEETH",
                                                "DOGE/USDT": "BINANCE:DOGEUSDT",
                                                "DOGE/BUSD": "BINANCE:DOGEBUSD",
                                                "DOGE/USDC": "POLONIEX:DOGEUSDC",
                                                "DGB/USDT": "BINANCE:DGBUSDT",
                                                "DGB/BUSD": "BINANCE:DGBBUSD",
                                                "DGB/BTC": "BINANCE:DGBBTC",
                                                "DGB/ETH": "BITTREX:DGBETH",
                                                "DGB/BNB": "BINANCE:DGBBNB",
                                                "DGB/TUSD": "HITBTC:DGBTUSD",
                                                "DIA/BTC": "BINANCE:DIABTC",
                                                "DIA/ETH": "OKEX:DIAETH",
                                                "DIA/USDT": "BINANCE:DIAUSDT",
                                                "DIA/BUSD": "BINANCE:DIABUSD",
                                                "DIA/USDC": "UNISWAP:DIAUSDC",
                                                "DODO/BTC": "BINANCE:DODOBTC",
                                                "DODO/USDT": "BINANCE:DODOUSDT",
                                                "DODO/BUSD": "BINANCE:DODOBUSD",
                                                "DX/BTC": "KUCOIN:DXBTC",
                                                "DX/ETH": "KUCOIN:DXETH",
                                                "ELF/BTC": "BINANCE:ELFBTC",
                                                "ELF/ETH": "BINANCE:ELFETH",
                                                "ELF/USDT": "HUOBI:ELFUSDT",
                                                "EMC2/BTC": "BITTREX:EMC2BTC",
                                                "ENJ/BTC": "BINANCE:ENJBTC",
                                                "ENJ/ETH": "BINANCE:ENJETH",
                                                "ENJ/USDT": "BINANCE:ENJUSDT",
                                                "ENJ/BUSD": "BINANCE:ENJBUSD",
                                                "ETH/BTC": "BINANCE:ETHBTC",
                                                "ETH/USDT": "BINANCE:ETHUSDT",
                                                "ETH/BUSD": "BINANCE:ETHBUSD",
                                                "ETH/DAI": "BINANCE:ETHDAI",
                                                "ETH/EURS": "HITBTC:ETHEURS",
                                                "ETH/HUSD": "HUOBI:ETHHUSD",
                                                "ETH/PAX": "BINANCE:ETHPAX",
                                                "ETH/TUSD": "BINANCE:ETHTUSD",
                                                "ETH/USDC": "BINANCE:ETHUSDC",
                                                "EURS/USDT": "HITBTC:EURSUSDT",
                                                "EURS/DAI": "HITBTC:EURSDAI",
                                                "EURS/TUSD": "HITBTC:EURSTUSD",
                                                "FET/BTC": "BINANCE:FETBTC",
                                                "FET/ETH": "KUCOIN:FETETH",
                                                "FET/USDT": "BINANCE:FETUSDT",
                                                "FIRO/BTC": "BINANCE:FIROBTC",
                                                "FIRO/ETH": "BINANCE:FIROETH",
                                                "FIRO/USDT": "BINANCE:FIROUSDT",
                                                "FTC/BTC": "BITTREX:FTCBTC",
                                                "FUN/BTC": "BINANCE:FUNBTC",
                                                "FUN/ETH": "BINANCE:FUNETH",
                                                "FUN/USDT": "BINANCE:FUNUSDT",
                                                "GLEEC/BTC": "BITTREX:GLEECBTC",
                                                "GLEEC/USDT": "BITTREX:GLEECUSDT",
                                                "GNO/BTC": "BITTREX:GNOBTC",
                                                "GNO/ETH": "KRAKEN:GNOETH",
                                                "GRS/BTC": "BINANCE:GRSBTC",
                                                "GRS/ETH": "HUOBI:GRSETH",
                                                "HEX/BTC": "HITBTC:HEXBTC",
                                                "HEX/USDC": "UNISWAP:HEXUSDC",
                                                "HOT/BTC": "HUOBI:HOTBTC",
                                                "HOT/ETH": "BINANCE:HOTETH",
                                                "HOT/USDT": "BINANCE:HOTUSDT",
                                                "HT/BTC": "HUOBI:HTBTC",
                                                "HT/ETH": "HUOBI:HTETH",
                                                "HT/USDT": "HUOBI:HTUSDT",
                                                "HT/HUSD": "HUOBI:HTHUSD",
                                                "INK/BTC": "HITBTC:INKBTC",
                                                "INK/ETH": "HITBTC:INKETH",
                                                "INK/USDT": "HITBTC:INKUSDT",
                                                "KMD/BTC": "BINANCE:KMDBTC",
                                                "KMD/ETH": "BINANCE:KMDETH",
                                                "KMD/USDT": "BINANCE:KMDUSDT",
                                                "KNC/BTC": "BINANCE:KNCBTC",
                                                "KNC/ETH": "BINANCE:KNCETH",
                                                "KNC/USDT": "BINANCE:KNCUSDT",
                                                "KNC/BUSD": "BINANCE:KNCBUSD",
                                                "KNC/HUSD": "HUOBI:KNCHUSD",
                                                "LEO/BTC": "BITFINEX:LEOBTC",
                                                "LEO/ETH": "BITFINEX:LEOETH",
                                                "LEO/USDT": "OKEX:LEOUSDT",
                                                "LINK/BTC": "BINANCE:LINKBTC",
                                                "LINK/ETH": "BINANCE:LINKETH",
                                                "LINK/USDT": "BINANCE:LINKUSDT",
                                                "LINK/BUSD": "BINANCE:LINKBUSD",
                                                "LINK/HUSD": "HUOBI:LINKHUSD",
                                                "LINK/TUSD": "BINANCE:LINKTUSD",
                                                "LINK/USDC": "BINANCE:LINKUSDC",
                                                "LINK/BCH": "HITBTC:LINKBCH",
                                                "LRC/BTC": "BINANCE:LRCBTC",
                                                "LRC/ETH": "BINANCE:LRCETH",
                                                "LRC/USDT": "BINANCE:LRCUSDT",
                                                "LRC/BUSD": "BINANCE:LRCBUSD",
                                                "LTC/BTC": "BINANCE:LTCBTC",
                                                "LTC/ETH": "BINANCE:LTCETH",
                                                "LTC/BNB": "BINANCE:LTCBNB",
                                                "LTC/USDT": "BINANCE:LTCUSDT",
                                                "LTC/BUSD": "BINANCE:LTCBUSD",
                                                "LTC/DAI": "HITBTC:LTCDAI",
                                                "LTC/EURS": "HITBTC:LTCEURS",
                                                "LTC/HUSD": "HUOBI:LTCHUSD",
                                                "LTC/PAX": "BINANCE:LTCPAX",
                                                "LTC/TUSD": "BINANCE:LTCTUSD",
                                                "LTC/USDC": "BINANCE:LTCUSDC",
                                                "LTC/BCH": "HITBTC:LTCBCH",
                                                "LTC/HT": "HUOBI:LTCHT",
                                                "MANA/BTC": "BINANCE:MANABTC",
                                                "MANA/ETH": "BINANCE:MANAETH",
                                                "MANA/USDT": "BINANCE:MANAUSDT",
                                                "MANA/BUSD": "BINANCE:MANABUSD",
                                                "MANA/USDC": "COINBASE:MANAUSDC",
                                                "MATIC/BTC": "BINANCE:MATICBTC",
                                                "MATIC/ETH": "HUOBI:MATICETH",
                                                "MATIC/USDT": "BINANCE:MATICUSDT",
                                                "MATIC/BUSD": "BINANCE:MATICBUSD",
                                                "MED/BTC": "BITTREX:MEDBTC",
                                                "MKR/BTC": "BINANCE:MKRBTC",
                                                "MKR/ETH": "BITFINEX:MKRETH",
                                                "MKR/USDT": "BINANCE:MKRUSDT",
                                                "MKR/BUSD": "BINANCE:MKRBUSD",
                                                "MKR/DAI": "HITBTC:MKRDAI",
                                                "MKR/HUSD": "HUOBI:MKRHUSD",
                                                "MONA/BTC": "BITTREX:MONABTC",
                                                "NAV/BTC": "BINANCE:NAVBTC",
                                                "NAV/USDT": "HITBTC:NAVUSDT",
                                                "NPXS/BTC": "HUOBI:NPXSBTC",
                                                "NPXS/ETH": "BINANCE:NPXSETH",
                                                "NPXS/USDT": "BINANCE:NPXSUSDT",
                                                "OCEAN/BTC": "BINANCE:OCEANBTC",
                                                "OCEAN/ETH": "KUCOIN:OCEANETH",
                                                "OCEAN/USDT": "BINANCE:OCEANUSDT",
                                                "OCEAN/BUSD": "BINANCE:OCEANBUSD",
                                                "OKB/BTC": "OKEX:OKBBTC",
                                                "OKB/ETH": "OKEX:OKBETH",
                                                "OKB/USDT": "OKEX:OKBUSDT",
                                                "OKB/USDC": "OKEX:OKBUSDC",
                                                "PAXG/BTC": "BINANCE:PAXGBTC",
                                                "PAXG/ETH": "KRAKEN:PAXGETH",
                                                "PAXG/USDT": "BINANCE:PAXGUSDT",
                                                "PAXG/USDC": "UNISWAP:PAXGUSDC",
                                                "PAXG/BNB": "BINANCE:PAXGBNB",
                                                "PNK/BTC": "BITFINEX:PNKBTC",
                                                "PNK/ETH": "BITFINEX:PNKETH",
                                                "PNK/USDT": "OKEX:PNKUSDT",
                                                "POWR/BTC": "BINANCE:POWRBTC",
                                                "POWR/ETH": "BINANCE:POWRETH",
                                                "QKC/BTC": "BINANCE:QKCBTC",
                                                "QKC/ETH": "BINANCE:QKCETH",
                                                "QNT/BTC": "BITTREX:QNTBTC",
                                                "QNT/USDT": "KUCOIN:QNTUSDT",
                                                "QTUM/BTC": "BINANCE:QTUMBTC",
                                                "QTUM/ETH": "BINANCE:QTUMETH",
                                                "QTUM/USDT": "BINANCE:QTUMUSDT",
                                                "QTUM/BUSD": "BINANCE:QTUMBUSD",
                                                "QTUM/HUSD": "HUOBI:QTUMHUSD",
                                                "REN/BTC": "BINANCE:RENBTC",
                                                "REN/ETH": "HUOBI:RENETH",
                                                "REN/USDT": "BINANCE:RENUSDT",
                                                "REN/HUSD": "HUOBI:RENHUSD",
                                                "REP/BTC": "BINANCE:REPBTC",
                                                "REP/ETH": "BINANCE:REPETH",
                                                "REP/USDT": "BINANCE:REPUSDT",
                                                "REV/BTC": "BITTREX:REVBTC",
                                                "REV/USDT": "KUCOIN:REVUSDT",
                                                "RLC/BTC": "BINANCE:RLCBTC",
                                                "RLC/ETH": "BINANCE:RLCETH",
                                                "RLC/USDT": "BINANCE:RLCUSDT",
                                                "RSR/BTC": "BINANCE:RSRBTC",
                                                "RSR/ETH": "OKEX:RSRETH",
                                                "RSR/USDT": "BINANCE:RSRUSDT",
                                                "RSR/BUSD": "BINANCE:RSRBUSD",
                                                "RSR/HUSD": "HUOBI:RSRHUSD",
                                                "RSR/BNB": "BINANCE:RSRBNB",
                                                "RVN/BTC": "BINANCE:RVNBTC",
                                                "RVN/USDT": "BINANCE:RVNUSDT",
                                                "RVN/BUSD": "BINANCE:RVNBUSD",
                                                "RVN/BNB": "BINANCE:RVNBNB",
                                                "RVN/HT": "HUOBI:RVNHT",
                                                "SHR/BTC": "KUCOIN:SHRBTC",
                                                "SHR/USDT": "KUCOIN:SHRUSDT",
                                                "SKL/BTC": "BINANCE:SKLBTC",
                                                "SKL/ETH": "HUOBI:SKLETH",
                                                "SKL/USDT": "BINANCE:SKLUSDT",
                                                "SKL/BUSD": "BINANCE:SKLBUSD",
                                                "SNT/BTC": "BINANCE:SNTBTC",
                                                "SNT/ETH": "BINANCE:SNTETH",
                                                "SNT/USDT": "HUOBI:SNTUSDT",
                                                "SNX/BTC": "BINANCE:SNXBTC",
                                                "SNX/ETH": "KRAKEN:SNXETH",
                                                "SNX/USDT": "BINANCE:SNXUSDT",
                                                "SNX/HUSD": "HUOBI:SNXHUSD",
                                                "SPC/BTC": "BITTREX:SPCBTC",
                                                "SPC/ETH": "HITBTC:SPCETH",
                                                "SPC/USDT": "HITBTC:SPCUSDT",
                                                "SRM/BTC": "BINANCE:SRMBTC",
                                                "SRM/USDT": "BINANCE:SRMUSDT",
                                                "SRM/BUSD": "BINANCE:SRMBUSD",
                                                "STORJ/BTC": "BINANCE:STORJBTC",
                                                "STORJ/ETH": "KRAKEN:STORJETH",
                                                "STORJ/USDT": "BINANCE:STORJUSDT",
                                                "SUSHI/BTC": "BINANCE:SUSHIBTC",
                                                "SUSHI/ETH": "OKEX:SUSHIETH",
                                                "SUSHI/USDT": "BINANCE:SUSHIUSDT",
                                                "SUSHI/BUSD": "BINANCE:SUSHIBUSD",
                                                "SXP/BTC": "BINANCE:SXPBTC",
                                                "SXP/USDT": "BINANCE:SXPUSDT",
                                                "SXP/BUSD": "BINANCE:SXPBUSD",
                                                "TMTG/BTC": "OKEX:TMTGBTC",
                                                "TMTG/USDT": "OKEX:TMTGUSDT",
                                                "TRAC/BTC": "KUCOIN:TRACBTC",
                                                "TRAC/ETH": "KUCOIN:TRACETH",
                                                "TRAC/USDT": "BITTREX:TRACUSDT",
                                                "THC/BTC": "BITTREX:THCBTC",
                                                "UBT/BTC": "BITTREX:UBTBTC",
                                                "UBT/ETH": "BITTREX:UBTETH",
                                                "UMA/BTC": "BINANCE:UMABTC",
                                                "UMA/ETH": "OKEX:UMAETH",
                                                "UMA/USDT": "BINANCE:UMAUSDT",
                                                "UNI/BTC": "BINANCE:UNIBTC",
                                                "UNI/ETH": "KRAKEN:UNIETH",
                                                "UNI/BNB": "BINANCE:UNIBNB",
                                                "UNI/USDT": "BINANCE:UNIUSDT",
                                                "UNI/BUSD": "BINANCE:UNIBUSD",
                                                "UOS/BTC": "BITFINEX:UOSBTC",
                                                "UOS/USDT": "KUCOIN:UOSUSDT",
                                                "UQC/BTC": "BITTREX:UQCBTC",
                                                "UQC/ETH": "KUCOIN:UQCETH",
                                                "UQC/USDT": "BITTREX:UQCUSDT",
                                                "USDC/EURS": "UNISWAP:USDCEURS",
                                                "UTK/BTC": "BINANCE:UTKBTC",
                                                "UTK/ETH": "KUCOIN:UTKETH",
                                                "UTK/USDT": "BINANCE:UTKUSDT",
                                                "VRA/BTC": "KUCOIN:VRABTC",
                                                "VRA/ETH": "HITBTC:VRAETH",
                                                "VRA/USDT": "KUCOIN:VRAUSDT",
                                                "WBTC/BTC": "BINANCE:WBTCBTC",
                                                "WBTC/ETH": "BINANCE:WBTCETH",
                                                "WBTC/USDT": "BITTREX:WBTCUSDT",
                                                "WBTC/USDC": "UNISWAP:WBTCUSDC",
                                                "XRP/BTC": "BINANCE:XRPBTC",
                                                "XRP/ETH": "BINANCE:XRPETH",
                                                "XRP/USDT": "BINANCE:XRPUSDT",
                                                "XRP/BUSD": "BINANCE:XRPBUSD",
                                                "XRP/DAI": "HITBTC:XRPDAI",
                                                "XRP/PAX": "BINANCE:XRPPAX",
                                                "XRP/TUSD": "BINANCE:XRPTUSD",
                                                "XRP/USDC": "BINANCE:XRPUSDC",
                                                "XRP/EURS": "HITBTC:XRPEURS",
                                                "XRP/HUSD": "HUOBI:XRPHUSD",
                                                "XRP/BCH": "HITBTC:XRPBCH",
                                                "YFI/BTC": "BINANCE:YFIBTC",
                                                "YFI/ETH": "HUOBI:YFIETH",
                                                "YFI/BNB": "BINANCE:YFIBNB",
                                                "YFI/USDT": "BINANCE:YFIUSDT",
                                                "YFI/BUSD": "BINANCE:YFIBUSD",
                                                "YFI/HUSD": "HUOBI:YFIHUSD",
                                                "YFII/BTC": "BINANCE:YFIIBTC",
                                                "YFII/ETH": "HUOBI:YFIIETH",
                                                "YFII/USDT": "BINANCE:YFIIUSDT",
                                                "YFII/BUSD": "BINANCE:YFIIBUSD",
                                                "ZEC/BTC": "BINANCE:ZECBTC",
                                                "ZEC/ETH": "BINANCE:ZECETH",
                                                "ZEC/BNB": "BINANCE:ZECBNB",
                                                "ZEC/USDT": "BINANCE:ZECUSDT",
                                                "ZEC/BUSD": "BINANCE:ZECBUSD",
                                                "ZEC/USDC": "BINANCE:ZECUSDC",
                                                "ZEC/EURS": "HITBTC:ZECEURS",
                                                "ZEC/HUSD": "HUOBI:ZECHUSD",
                                                "ZEC/BCH": "HITBTC:ZECBCH",
                                                "ZEC/LTC": "GEMINI:ZECLTC",
                                                "ZRX/BTC": "BINANCE:ZRXBTC",
                                                "ZRX/ETH": "BINANCE:ZRXETH",
                                                "ZRX/USDT": "BINANCE:ZRXUSDT",
                                                "ZRX/BUSD": "BINANCE:ZRXBUSD",
                                                "ZRX/HUSD": "HUOBI:ZRXHUSD",
                                                "ZRX/TUSD": "HITBTC:ZRXTUSD"
                                            })
}
