pragma Singleton
import QtQuick 2.10

QtObject {
    // Mock API
    property string saved_seed
    property string saved_password
    property var update_info: ({
                "update_needed": true,
                "new_version": "0.1.5",
                "version_num": "015",
                "changelog": "blabla",
                "status": "available",
                "download_url": "https://github.com/KomodoPlatform/AtomicDeFi-Pro/releases/tag/0.1.5-alpha"
              })

    property var mockAPI: ({
        empty_string: '',
        // Signals
        myOrdersUpdated: {
           connect: (func) => { console.log("Connecting function") }
       },
        OHLCDataUpdated: {
          connect: (func) => { console.log("Connecting function") }
        },


        // Other
        addressbook_mdl: [
            {
                name: "ca333",
                addresses: [
                     { type: "ERC-20", address: "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae" },
                     { type: "SmartChains", address: "RB49Rm4jBe5mN9anErvkzf3kcQCzHqyz3e" },
                     { type: "BTC", address: "3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5" }
                ]
            },
            {
                name: "alice",
                addresses: [
                     { type: "ERC-20", address: "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae" },
                     { type: "SmartChains", address: "RB49Rm4jBe5mN9anErvkzf3kcQCzHqyz3e" },
                     { type: "BTC", address: "3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5" }
                ]
            },
            {
                name: "bob",
                addresses: [
                     { type: "ERC-20", address: "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae" },
                     { type: "SmartChains", address: "RB49Rm4jBe5mN9anErvkzf3kcQCzHqyz3e" },
                     { type: "BTC", address: "3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5" }
                ]
            },
        ],
       add_contact: (name) => {
         address_book[name] = {}

         address_book = address_book
       },
       update_contact: (old_name, new_name) => {
         address_book[new_name] = General.clone(address_book[old_name])
         delete address_book[old_name]

         address_book = address_book
       },
       insert_or_update_address: (name, ticker, address) => {
         address_book[name][ticker] = address

         address_book = address_book
       },

        to_eth_checksum_qt: (addr) => { return "0xA00bF635b2cD52F2b6B4D8cd9B9efd290B97838C" },
        retrieve_seed: (wallet_name, password) => { return "this is a test seed gossip rubber flee just connect manual any salmon limb suffer now turkey essence naive daughter system begin quantum page" },
        get_log_folder: () => { return "D:/Projects/AtomicDeFi-Pro/atomic_qt_design" },
        get_mm2_version: () => { return "5.1.1" },
        get_version: () => { return "0.1.1-alpha" },

        mnemonic_validate: (entropy) => { return true },
        wallet_default_name: "",

        balance_fiat_all: "12345678.90",

        current_fiat: "EUR",
        current_currency: "EUR",
        get_available_fiats: () => ["USD", "EUR"],
        get_available_currencies: () => ["EUR", "BTC", "KMD"],

        lang: "en",
        get_available_langs: () => ["en", "fr", "tr"],

        get_cex_rates: (base, rel) => {
                                   if(rel === "USD") return "9531.53"
                                   if(rel === "EUR") return "6234.152"
                                   return "25"
                               },

        confirm_password: (wallet_name, password)  => { return true },

        current_coin_info: {"objectName":"","is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"ETH","name":"Ethereum","paprika_id":"dash-dash","type":"ERC-20","balance":"0.009","address":"0x6A0DFcC3442aB5B2A252cE028aC9516Ecd29b9fB","fiat_amount":"2.04","explorer_url":"https://explorer.dash.org/","transactions":[{"objectName":"","received":true,"blockheight":9722988,"confirmations":645576,"timestamp":1584902263,"amount":"0.009","amount_fiat":"2.04","date":"22 Mar 2020, 09:37","tx_hash":"0x8140a94a5701167c88a015ec6e4dc26ef256335b81310c8a1946f175b06a2248","fees":"0.000168","to":["0x6A0DFcC3442aB5B2A252cE028aC9516Ecd29b9fB"],"from":["0x6c5CB1014e292624afDD0C36eBE3f1A870D12f7e"]}],"tx_state":"InProgress","transactions_left":0,"blocks_left":4414770,"tx_current_block":10368563},

        get_coin_info: (ticker) => {
            const data = { "MORTY": { explorer_url: "https://morty.kmd.dev/" }, "RICK": { explorer_url: "https://rick.kmd.dev/" }, "KMD": { explorer_url: "https://kmdexplorer.io/" } }
            return data[ticker]
        },

        get_portfolio_informations: () => [{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":1629131,"price":0.263641,"timestamp":"2020-03-01T00:00:00Z","volume_24h":5201},{"market_cap":1586771,"price":0.256805,"timestamp":"2020-03-02T00:00:00Z","volume_24h":4959},{"market_cap":1499993,"price":0.242853,"timestamp":"2020-03-03T00:00:00Z","volume_24h":2548},{"market_cap":1379019,"price":0.223283,"timestamp":"2020-03-04T00:00:00Z","volume_24h":3352},{"market_cap":1561534,"price":0.251818,"timestamp":"2020-03-05T00:00:00Z","volume_24h":5090},{"market_cap":1612940,"price":0.259118,"timestamp":"2020-03-06T00:00:00Z","volume_24h":3860}],"name":"Atomic Wallet Coin","price":"0.24","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":1342122.5112865071,"market_cap_change_24h":-12.31,"percent_change_12h":-0.82,"percent_change_1h":0.04,"percent_change_1y":822.62,"percent_change_24h":-12.3,"percent_change_30d":-9.41,"percent_change_7d":-15.56,"percent_from_price_ath":null,"price":0.21561442256146196,"volume_24h":3225.3856958132146,"volume_24h_change_24h":133.98},"USD":{"ath_date":"2019-07-14T15:01:29Z","ath_price":0.39188476,"market_cap":1514746,"market_cap_change_24h":-12.31,"percent_change_12h":-0.82,"percent_change_1h":0.04,"percent_change_1y":830.39,"percent_change_24h":-12.3,"percent_change_30d":-6.89,"percent_change_7d":-13.58,"percent_from_price_ath":-37.9,"price":0.2433467,"volume_24h":3640.23406217,"volume_24h_change_24h":133.97}},"ticker":"AWC"},{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":5742512999,"price":313.68,"timestamp":"2020-03-01T00:00:00Z","volume_24h":3086371803},{"market_cap":5976167243,"price":326.42,"timestamp":"2020-03-02T00:00:00Z","volume_24h":5687032813},{"market_cap":6077734127,"price":331.93,"timestamp":"2020-03-03T00:00:00Z","volume_24h":3249683525},{"market_cap":5936073770,"price":324.16,"timestamp":"2020-03-04T00:00:00Z","volume_24h":2752609409},{"market_cap":6150234284,"price":335.82,"timestamp":"2020-03-05T00:00:00Z","volume_24h":2992184313},{"market_cap":6333544480,"price":345.8,"timestamp":"2020-03-06T00:00:00Z","volume_24h":3337082985}],"name":"Bitcoin Cash","price":"348.00","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":5647998320.993438,"market_cap_change_24h":-0.86,"percent_change_12h":-0.11,"percent_change_1h":-0.17,"percent_change_1y":167.45,"percent_change_24h":-0.87,"percent_change_30d":-22.95,"percent_change_7d":8.41,"percent_from_price_ath":null,"price":308.3410325516449,"volume_24h":2428150654.779953,"volume_24h_change_24h":-18.43},"USD":{"ath_date":"2017-12-20T16:59:00Z","ath_price":4355.62,"market_cap":6374442566,"market_cap_change_24h":-0.86,"percent_change_12h":-0.11,"percent_change_1h":-0.17,"percent_change_1y":169.7,"percent_change_24h":-0.87,"percent_change_30d":-20.81,"percent_change_7d":10.95,"percent_from_price_ath":-92.01,"price":347.99978524,"volume_24h":2740458833.5231,"volume_24h_change_24h":-18.43}},"ticker":"BCH"},{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":156726234822,"price":8589.68,"timestamp":"2020-03-01T00:00:00Z","volume_24h":25754988975},{"market_cap":159982691663,"price":8767.19,"timestamp":"2020-03-02T00:00:00Z","volume_24h":28674357442},{"market_cap":160860405980,"price":8814.37,"timestamp":"2020-03-03T00:00:00Z","volume_24h":31363098490},{"market_cap":160378394181,"price":8787,"timestamp":"2020-03-04T00:00:00Z","volume_24h":29714878468},{"market_cap":164941681945,"price":9035.95,"timestamp":"2020-03-05T00:00:00Z","volume_24h":29101185235},{"market_cap":166252867067,"price":9106.84,"timestamp":"2020-03-06T00:00:00Z","volume_24h":29690581038}],"name":"Bitcoin","price":"9143.72","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":147918127329.1004,"market_cap_change_24h":-0.16,"percent_change_12h":0.3,"percent_change_1h":0.08,"percent_change_1y":131.56,"percent_change_24h":-0.17,"percent_change_30d":-7.94,"percent_change_7d":2.58,"percent_from_price_ath":null,"price":8101.679297466144,"volume_24h":25305595410.959354,"volume_24h_change_24h":-1.55},"USD":{"ath_date":"2017-12-17T12:19:00Z","ath_price":20089,"market_cap":166943322845,"market_cap_change_24h":-0.16,"percent_change_12h":0.3,"percent_change_1h":0.08,"percent_change_1y":133.51,"percent_change_24h":-0.17,"percent_change_30d":-5.38,"percent_change_7d":4.98,"percent_from_price_ath":-54.48,"price":9143.71542532,"volume_24h":28560395272.43,"volume_24h_change_24h":-1.55}},"ticker":"BTC"},{"balance":"0","balance_fiat":"0.00","historical":[],"name":"Chips","price":"0.00","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":1947683.4080267795,"market_cap_change_24h":1.46,"percent_change_12h":4.79,"percent_change_1h":-0.02,"percent_change_1y":170.97,"percent_change_24h":1.46,"percent_change_30d":23.05,"percent_change_7d":-7.25,"percent_from_price_ath":null,"price":0.09276742511784992,"volume_24h":0.0096619165195024,"volume_24h_change_24h":1.46},"USD":{"ath_date":"2018-02-23T01:59:00Z","ath_price":1.74579,"market_cap":2198194,"market_cap_change_24h":1.46,"percent_change_12h":4.79,"percent_change_1h":-0.02,"percent_change_1y":173.25,"percent_change_24h":1.46,"percent_change_30d":26.47,"percent_change_7d":-5.08,"percent_from_price_ath":-94,"price":0.10469915,"volume_24h":0.01090463,"volume_24h_change_24h":1.46}},"ticker":"CHIPS"},{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":808294279,"price":86.37,"timestamp":"2020-03-01T00:00:00Z","volume_24h":574702715},{"market_cap":823679696,"price":88,"timestamp":"2020-03-02T00:00:00Z","volume_24h":571312836},{"market_cap":830394342,"price":88.7,"timestamp":"2020-03-03T00:00:00Z","volume_24h":583597576},{"market_cap":824569636,"price":88.07,"timestamp":"2020-03-04T00:00:00Z","volume_24h":546896214},{"market_cap":844318623,"price":90.16,"timestamp":"2020-03-05T00:00:00Z","volume_24h":508227152},{"market_cap":857435401,"price":91.54,"timestamp":"2020-03-06T00:00:00Z","volume_24h":489668329}],"name":"Dash","price":"92.57","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":768377649.454076,"market_cap_change_24h":1.13,"percent_change_12h":-0.25,"percent_change_1h":-0.01,"percent_change_1y":10.33,"percent_change_24h":1.11,"percent_change_30d":-26.17,"percent_change_7d":3.24,"percent_from_price_ath":null,"price":82.02048347956902,"volume_24h":454054618.58537173,"volume_24h_change_24h":9.7},"USD":{"ath_date":"2017-12-20T14:59:00Z","ath_price":1642.22,"market_cap":867206206,"market_cap_change_24h":1.13,"percent_change_12h":-0.25,"percent_change_1h":-0.01,"percent_change_1y":11.26,"percent_change_24h":1.11,"percent_change_30d":-24.12,"percent_change_7d":5.66,"percent_from_price_ath":-94.36,"price":92.5699392,"volume_24h":512455019.19526,"volume_24h_change_24h":9.7}},"ticker":"DASH"},{"balance":"0","balance_fiat":"0.00","historical":[],"name":"Dex","price":"0.00","rates":null,"ticker":"DEX"},{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":24208598380,"price":220.25,"timestamp":"2020-03-01T00:00:00Z","volume_24h":12847564617},{"market_cap":24779447338,"price":225.42,"timestamp":"2020-03-02T00:00:00Z","volume_24h":13648741499},{"market_cap":24987569401,"price":227.28,"timestamp":"2020-03-03T00:00:00Z","volume_24h":14737702685},{"market_cap":24717395333,"price":224.8,"timestamp":"2020-03-04T00:00:00Z","volume_24h":14103677652},{"market_cap":25307090407,"price":230.13,"timestamp":"2020-03-05T00:00:00Z","volume_24h":12782838158},{"market_cap":25938079804,"price":235.84,"timestamp":"2020-03-06T00:00:00Z","volume_24h":13633636399}],"name":"Ethereum","price":"245.14","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":23890827922.498646,"market_cap_change_24h":3.27,"percent_change_12h":2.33,"percent_change_1h":0.11,"percent_change_1y":77.34,"percent_change_24h":3.25,"percent_change_30d":13.88,"percent_change_7d":6.45,"percent_from_price_ath":null,"price":217.1991898033117,"volume_24h":12790591664.983858,"volume_24h_change_24h":7.6},"USD":{"ath_date":"2018-01-13T21:04:00Z","ath_price":1432.88,"market_cap":26963660715,"market_cap_change_24h":3.27,"percent_change_12h":2.33,"percent_change_1h":0.11,"percent_change_1y":78.83,"percent_change_24h":3.25,"percent_change_30d":17.05,"percent_change_7d":8.94,"percent_from_price_ath":-82.89,"price":245.13529964,"volume_24h":14435714623.098,"volume_24h_change_24h":7.6}},"ticker":"ETH"},{"balance":"10.65581933","balance_fiat":"6.84","historical":[{"market_cap":69616966,"price":0.587165,"timestamp":"2020-03-01T00:00:00Z","volume_24h":695641},{"market_cap":73140722,"price":0.616809,"timestamp":"2020-03-02T00:00:00Z","volume_24h":794110},{"market_cap":73591240,"price":0.620508,"timestamp":"2020-03-03T00:00:00Z","volume_24h":1141006},{"market_cap":74346224,"price":0.626711,"timestamp":"2020-03-04T00:00:00Z","volume_24h":1451238},{"market_cap":76556127,"price":0.645202,"timestamp":"2020-03-05T00:00:00Z","volume_24h":1558428},{"market_cap":76501543,"price":0.644677,"timestamp":"2020-03-06T00:00:00Z","volume_24h":1494849}],"name":"Komodo","price":"0.64","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":67457385.58168267,"market_cap_change_24h":-1.42,"percent_change_12h":-0.76,"percent_change_1h":0.09,"percent_change_1y":-30.57,"percent_change_24h":-1.43,"percent_change_30d":-15.45,"percent_change_7d":4.38,"percent_from_price_ath":null,"price":0.5684297112746838,"volume_24h":1226004.1380420795,"volume_24h_change_24h":-11.34},"USD":{"ath_date":"2017-12-21T08:04:00Z","ath_price":15.4149,"market_cap":76133739,"market_cap_change_24h":-1.42,"percent_change_12h":-0.76,"percent_change_1h":0.09,"percent_change_1y":-29.99,"percent_change_24h":-1.43,"percent_change_30d":-13.1,"percent_change_7d":6.83,"percent_from_price_ath":-95.84,"price":0.64154101,"volume_24h":1383692.5082961,"volume_24h_change_24h":-11.34}},"ticker":"KMD"},{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":3758798795,"price":58.55,"timestamp":"2020-03-01T00:00:00Z","volume_24h":3266358812},{"market_cap":3837348531,"price":59.77,"timestamp":"2020-03-02T00:00:00Z","volume_24h":3630550651},{"market_cap":3910766258,"price":60.91,"timestamp":"2020-03-03T00:00:00Z","volume_24h":4460998961},{"market_cap":3887248616,"price":60.53,"timestamp":"2020-03-04T00:00:00Z","volume_24h":4236552516},{"market_cap":3980099044,"price":61.97,"timestamp":"2020-03-05T00:00:00Z","volume_24h":3695111410},{"market_cap":4010190134,"price":62.43,"timestamp":"2020-03-06T00:00:00Z","volume_24h":4060682299}],"name":"Litecoin","price":"63.75","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":3617023418.7905464,"market_cap_change_24h":0.88,"percent_change_12h":1.42,"percent_change_1h":-0.04,"percent_change_1y":11.93,"percent_change_24h":0.86,"percent_change_30d":-15.38,"percent_change_7d":4.91,"percent_from_price_ath":null,"price":56.305932838656545,"volume_24h":3510859213.114528,"volume_24h_change_24h":-1.92},"USD":{"ath_date":"2017-12-19T04:39:00Z","ath_price":375.286,"market_cap":4082244139,"market_cap_change_24h":0.88,"percent_change_12h":1.42,"percent_change_1h":-0.04,"percent_change_1y":12.87,"percent_change_24h":0.86,"percent_change_30d":-13.03,"percent_change_7d":7.37,"percent_from_price_ath":-83.07,"price":63.54798897,"volume_24h":3962425117.6077,"volume_24h_change_24h":-1.92}},"ticker":"LTC"},{"balance":"19.80469258","balance_fiat":"0.00","historical":[],"name":"Morty (TESTCOIN)","price":"0.00","rates":null,"ticker":"MORTY"},{"balance":"519.98869877","balance_fiat":"0.00","historical":[],"name":"Rick (TESTCOIN)","price":"0.00","rates":null,"ticker":"RICK"},{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":142642750,"price":1.002227,"timestamp":"2020-03-01T00:00:00Z","volume_24h":730801071},{"market_cap":142335054,"price":1.001743,"timestamp":"2020-03-02T00:00:00Z","volume_24h":1026815204},{"market_cap":141164240,"price":1.001742,"timestamp":"2020-03-03T00:00:00Z","volume_24h":1079166559},{"market_cap":137539410,"price":1.001821,"timestamp":"2020-03-04T00:00:00Z","volume_24h":1016218356},{"market_cap":136699980,"price":1.001912,"timestamp":"2020-03-05T00:00:00Z","volume_24h":1039662691},{"market_cap":137037015,"price":1.001995,"timestamp":"2020-03-06T00:00:00Z","volume_24h":740192613}],"name":"True USD","price":"1.00","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":121636177.78908835,"market_cap_change_24h":0.84,"percent_change_12h":0.06,"percent_change_1h":-0.09,"percent_change_1y":-1.86,"percent_change_24h":-0.23,"percent_change_30d":-2.95,"percent_change_7d":-2.53,"percent_from_price_ath":null,"price":0.8864088212808818,"volume_24h":396101374.0770995,"volume_24h_change_24h":-44.19},"USD":{"ath_date":"2018-05-16T10:31:08Z","ath_price":1.36449,"market_cap":137280995,"market_cap_change_24h":0.84,"percent_change_12h":0.06,"percent_change_1h":-0.09,"percent_change_1y":-1.03,"percent_change_24h":-0.23,"percent_change_30d":-0.25,"percent_change_7d":-0.25,"percent_from_price_ath":-26.68,"price":1.00041852,"volume_24h":447047841.70758,"volume_24h_change_24h":-44.19}},"ticker":"TUSD"},{"balance":"0","balance_fiat":"0.00","historical":[{"market_cap":439831391,"price":1.001887,"timestamp":"2020-03-01T00:00:00Z","volume_24h":737810541},{"market_cap":438515961,"price":1.002146,"timestamp":"2020-03-02T00:00:00Z","volume_24h":756269922},{"market_cap":452278446,"price":1.001424,"timestamp":"2020-03-03T00:00:00Z","volume_24h":857667879},{"market_cap":461575284,"price":1.001367,"timestamp":"2020-03-04T00:00:00Z","volume_24h":769993345},{"market_cap":462428608,"price":1.002286,"timestamp":"2020-03-05T00:00:00Z","volume_24h":655687454},{"market_cap":458434716,"price":1.000652,"timestamp":"2020-03-06T00:00:00Z","volume_24h":889900917}],"name":"USD Coin","price":"1.00","rates":{"EUR":{"ath_date":null,"ath_price":null,"market_cap":407796601.861759,"market_cap_change_24h":0.47,"percent_change_12h":-0.05,"percent_change_1h":0,"percent_change_1y":-1.74,"percent_change_24h":-0.05,"percent_change_30d":-3.22,"percent_change_7d":-2.37,"percent_from_price_ath":null,"price":0.8865477343179979,"volume_24h":1021284448.2512476,"volume_24h_change_24h":45.82},"USD":{"ath_date":"2018-10-11T06:36:14Z","ath_price":1.90619801,"market_cap":460247307,"market_cap_change_24h":0.47,"percent_change_12h":-0.05,"percent_change_1h":0,"percent_change_1y":-0.91,"percent_change_24h":-0.05,"percent_change_30d":-0.53,"percent_change_7d":-0.08,"percent_from_price_ath":-47.51,"price":1.0005753,"volume_24h":1152641819.0899,"volume_24h_change_24h":45.82}},"ticker":"USDC"}],

        enabled_coins: [{"objectName":"","active":true,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"ETH","name":"Ethereum","type":"ERC-20","explorer_url":"https://etherscan.io/","balance":"0"},{"objectName":"","active":true,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"MORTY","name":"Morty (TESTCOIN)","type":"Smart Chain","explorer_url":"https://morty.kmd.dev/","balance":"70.92966258"},{"objectName":"","active":true,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"RICK","name":"Rick (TESTCOIN)","type":"Smart Chain","explorer_url":"https://rick.kmd.dev/","balance":"417.46416577"}],

        enableable_coins: [{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"BTC","name":"Bitcoin","type":"UTXO","explorer_url":"https://blockstream.info/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"LTC","name":"Litecoin","type":"UTXO","explorer_url":"https://blockexplorer.one/litecoin/mainnet/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"DASH","name":"Dash","type":"UTXO","explorer_url":"https://explorer.dash.org/"},{"objectName":"","active":false,"is_claimable":true,"minimal_balance_for_asking_rewards":"10","ticker":"KMD","name":"Komodo","type":"Smart Chain","explorer_url":"https://kmdexplorer.io/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"TUSD","name":"True USD","type":"ERC-20","explorer_url":"https://etherscan.io/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"USDC","name":"USD Coin","type":"ERC-20","explorer_url":"https://etherscan.io/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"CHIPS","name":"Chips","type":"Smart Chain","explorer_url":"https://explorer.chips.cash"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"DEX","name":"Dex","type":"Smart Chain","explorer_url":"https://dex.explorer.dexstats.info/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"ETH","name":"Ethereum","type":"ERC-20","explorer_url":"https://etherscan.io/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"BCH","name":"Bitcoin Cash","type":"UTXO","explorer_url":"https://explorer.bitcoin.com/bch/"},{"objectName":"","active":false,"is_claimable":false,"minimal_balance_for_asking_rewards":"0","ticker":"AWC","name":"Atomic Wallet Coin","type":"ERC-20","explorer_url":"https://etherscan.io/"}],

        get_price_amount: (base_amount, rel_amount) => (parseFloat(rel_amount) / parseFloat(base_amount)).toFixed(8).toString(),

        enable_coins: (coins) => {
            console.log("Enabling coins: ", coins)

            // Remove coins from enableable_coins, add them to enabled_coins
            for(let c of coins) {
               mockAPI.enableable_coins = mockAPI.enableable_coins.filter(obj => {
                   if(obj.ticker === c) {
                       mockAPI.enabled_coins.push(obj)

                       return false
                   }

                   return true
               });

            }
        },

        change_state: (visibility) => {
          console.log(visibility)
        },

        first_run: () => {
            return saved_seed === ''
        },

        get_mnemonic: () => {
            return "this is a test seed gossip rubber flee just connect manual any salmon limb suffer now turkey essence naive daughter system begin quantum page"
        },

        login: (password, wallet_name) => {
            console.log(wallet_name + " wallet: Logging in with password:" + password)

            const correct = password === saved_password

            if(correct) initialize_mm2.running = true

            return correct
        },

       is_there_a_default_wallet: () => { return true },
        disconnect: () => {},
        delete_wallet: (wallet_name) => {},


        create: (password, seed, wallet_name) => {
            console.log("Creating the seed with password:")
            console.log(seed)
            console.log(password)
            console.log(wallet_name)

            saved_seed = seed
            saved_password = password

            return saved_password !== ''
        },

        initial_loading_status: "initializing_mm2",

        prepare_send: (address, amount, max=true) => {
           console.log("Preparing to send " + amount + " to " + address)

           return {
                has_error: false,
                error_message: "",
                balance_change: amount,
                tx_hex: "abcdefghijklmnopqrstuvwxyz",
                date: "17. Oct 1963 14:26",
                fees: "0.0000125",
                explorer_url: "https://rick.explorer.dexstats.info/",
           }
        },

       prepare_send_fees: (address, amount, is_erc_20, fee_amount, gas_price, gas, max) => {
          console.log("Preparing to send " + amount + " to " + address)

          return {
               has_error: false,
               error_message: "",
               balance_change: amount,
               tx_hex: "abcdefghijklmnopqrstuvwxyz",
               date: "17. Oct 1963 14:26",
               fees: "0.0000125",
               explorer_url: "https://rick.explorer.dexstats.info/",
          }
       },

       send: (tx_hex) => {
          console.log("Sending tx hex:" + tx_hex)

          return "abcdefghijklmnopqrstuvwxyz"
       },

       disable_coins: (coins) => {
          for(let c of coins) {
                mockAPI.enabled_coins = mockAPI.enabled_coins.filter(ec => {
                    const keep = ec.ticker !== c
                    if(!keep) mockAPI.enableable_coins.push(ec)
                    return keep
                })
                console.log("Disabling " + c)
           }
       },

       on_gui_enter_dex: () => {
           console.log("on_gui_enter_dex")
       },

       on_gui_leave_dex: () => {
           console.log("on_gui_leave_dex")
       },

        place_sell_order: (base, rel, price, volume, is_created_order, price_denom, price_numer) => {
            console.log(`Selling ${volume} ${base} for ${price} ${rel} each ${is_created_order} / ${price_denom} / ${price_numer}`)

            return ""
        },

        place_buy_order: (base, rel, price, volume) => {
            console.log(`Buying ${volume} ${base} for ${price} ${rel} each`)

            return true
        },

        do_i_have_enough_funds: (ticker, amount) => {
            return parseFloat(mockAPI.current_coin_info.balance) >= parseFloat(amount)
        },

        get_balance: (ticker) => {
            switch(ticker) {
               case "BTC": return "0"
               case "KMD": return "5.555"
               case "CHIPS": return "0"
               case "ETH": return "4.44"
               case "RICK": return "3.33"
               case "MORTY": return "49538.555"
            }
        },

        get_orderbook: () => {
            return {"AWC":[],"BCH":[{"price":"0.002987200577122324183900402653676609639632640975848590186130652638701302662427533075896907369831854449","price_denom":"33476158503","price_numer":"100000000","volume":"5.86382416"},{"price":"0.003016486857235418266153292489842270694295395035965991487193676263401048433386983595256363214653508581","price_denom":"4143893407","price_numer":"12500000","volume":"0.89413813"}],"BTC":[],"CHIPS":[{"price":"1.014754345476190476190476190476190476190476190476192674449951738644311224489795918367346938775510204","price_denom":"19709203601010119303209234535426387905300235893287","price_numer":"20000000000000000000000000000000000000000000000000","volume":"41.50412631"}],"DASH":[{"price":"0.009685990477188629501329164789367543505748350289511707947672635185169885983856271722876178337378808977","price_denom":"5162094689","price_numer":"50000000","volume":"2.31970692"},{"price":"0.009970876921102391854218235049169448177556827895775064072850109565509504010451316845349404256087279837","price_denom":"5014604071","price_numer":"50000000","volume":"1.19027241"},{"price":"0.009874072290819544003113558828507012922397468292920158881817208213110512922082287905397199037237823415","price_denom":"632970857","price_numer":"6250000","volume":"3.00525747"}],"DEX":[{"price":"0.05555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555556","price_denom":"18","price_numer":"1","volume":"90.15955319"},{"price":"0.04014620599460546437300343583595933279902587190288942377445568565511713473778604314290187674215163472","price_denom":"622723851","price_numer":"25000000","volume":"20.05994512"},{"price":"0.04","price_denom":"25","price_numer":"1","volume":"10"},{"price":"0.04","price_denom":"25","price_numer":"1","volume":"2"},{"price":"0.02480972413793103603909828109393588835612389538235062405036518895076742318704661169779642282328262071","price_denom":"50383470330043","price_numer":"1250000000000","volume":"99.99999"}],"DGB":[{"price":"39.80945601970727310799588847938228463283340618463784939764312096580925060291421141846665122059773102","price_denom":"1255983","price_numer":"50000000","volume":"2469.3839591"}],"DOGE":[{"price":"286.5600472250957826957849882653660661323276986076047305332595918811807420185862846630197124656486143","price_denom":"348967","price_numer":"100000000","volume":"170489.59991676"}],"ETH":[],"LTC":[{"price":"0.01634405752056212943386017571383139478303064407392597524192817984346871820824414848312006708702142153","price_denom":"3059215861","price_numer":"50000000","volume":"4.51337168"},{"price":"0.01618537734974046092721177373901571415093240559173342482417849267677395648972764185262181716806207978","price_denom":"6178416347","price_numer":"100000000","volume":"11.60897171"}],"MORTY":[],"RICK":[{"price":"100.3344112618749999999999999999999999999999999999727807807558718506793125000000000000000000000000074","price_denom":"62291689574849488004532067555697962973556459571","price_numer":"6250000000000000000000000000000000000000000000000","volume":"6421.40232076"}],"RVN":[{"price":"32.43162602443398704680856584106557350465880307840994223927405048306906963394423706221358820267171735","price_denom":"308341","price_numer":"10000000","volume":"40339.54623441"},{"price":"32.74958293406133472890222743013367724762025155609643311192431964378933634280167442067625268792201931","price_denom":"1526737","price_numer":"50000000","volume":"573.43495931"}],"TUSD":[],"USDC":[],"XZC":[{"price":"0.1587435337547860917468825655134286004818129763723790829430185688391310316099823642442483316598298975","price_denom":"629946919","price_numer":"100000000","volume":"17.01674997"}],"ZEC":[{"price":"0.01330942857212990226044511939254111239130467353095094883980379528415000398978736721023899546702410798","price_denom":"7513470579","price_numer":"100000000","volume":"2.64741483"},{"price":"0.01369641984815186645880309693633491230788369324541385759846774688703787457133528969150315830545873691","price_denom":"7301178053","price_numer":"100000000","volume":"3.52814032"},{"price":"0.01356344489815177535849360113247269176946836251711617152382365820724485140531431847112819340534898716","price_denom":"7372758229999999","price_numer":"100000000000000","volume":"9.98586952"}]}
        },

        set_current_orderbook: (base, rel) => {
            console.log("Setting current orderbook: " + base)
        },

       recover_fund: (order_id) => {
            return '{"result": {"action": "RefundedMyPayment","coin": "HELLO","tx_hash": "696571d032976876df94d4b9994ee98faa870b44fbbb4941847e25fb7c49b85d","tx_hex": "0400008085202f890113591b1feb52878f8aea53b658cf9948ba89b0cb27ad0cf30b59b5d3ef6d8ef700000000d8483045022100eda93472c1f6aa18aacb085e456bc47b75ce88527ed01c279ee1a955e85691b702201adf552cfc85cecf588536d5b8257d4969044dde86897f2780e8c122e3a705e40120576fa34d308f39b7a704616656cc124232143565ca7cf1c8c60d95859af8f22d004c6b63042555555db1752102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ac6782012088a9146e602d4affeb86e4ee208802901b8fd43be2e2a4882102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ac68ffffffff0198929800000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac0238555d000000000000000000000000000000"}}'
      },


        cancel_order: (order_id) => {

      },

       cancel_all_orders: () => {

      },
       cancel_all_orders_by_ticker: (ticker) => {

      },

       get_fiat_from_amount: (ticker, amount) => { return (parseFloat(amount) * 157.213).toString() },

       is_claiming_ready: (ticker) => { return true },
       claim_rewards: (ticker) => { return {"objectName":"","has_error":false,"error_message":"","tx_hex":"0400008085202f8902755d841b4ecff907a7f49633af202e29363e3ed71fdc1918c5541648fc20ff36010000006a4730440220418adfffe0bc798af13d0241e6e45c4a2d4080a3dcdd90b497c31d155a52666c0220690ca5e11d9ddd681aae7a2eca137104701621961a5ca21bdb593c8cc6d20198012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff2de18d8aefe1967610ac76547ac70a56a724b25cb855e1451f63a327a3976107000000006b483045022100d49b5a5d6a5b9fcb368208cb1fb29eeed0fe864d6ef62d78e82f1fdc150d115d022078e119b15e63a7b1e5f927d8497d2269b91dddb42de5ea18d74662ecbd2558a7012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff0108365b3f000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88ac8dcd3e5e000000000000000000000000000000","date":" 8. Feb 2020 03:15","balance_change":"0.00147216","fees":"0.00001","explorer_url":"https://kmdexplorer.io/"} },

       send_rewards: (tx_hex) => {
          console.log("Sending tx hex:" + tx_hex)

          return "abcdefghijklmnopqrstuvwxyz"
       },

        refresh_orders_and_swaps: () => {
            console.log("refresh_orders_and_swaps!")
        },

        find_closest_ohlc_data: () => { return {"close":0.0000654,"high":0.0000655,"low":0.0000654,"open":0.0000655,"quote_volume":0.006986865,"timestamp":1593740820,"volume":106.83} },

        get_wallets: () => { return ["naezith", "slyris", "ca333", "tony"] },

        get_trade_infos: (ticker, receive_ticker, amount) => {
            return {"input_final_value":"3332.99997961","is_ticker_of_fees_eth":false,"trade_fee":"0.00000039","tx_fee":"0.0001", "not_enough_balance_to_pay_the_fees": false, "amount_needed":"0.01"}
       }
    })

    // Simulate initial loading
    property Timer initialize_mm2: Timer {
        interval: 1000
        onTriggered: {
            mockAPI.initial_loading_status = "enabling_coins"
            mockAPI = mockAPI
            enable_coins.running = true
        }
    }
    property Timer enable_coins: Timer {
        interval: 2000
        onTriggered: {
            mockAPI.initial_loading_status = "complete"
            mockAPI = mockAPI
        }
    }


    // Stuff to make it work both in C++ and Design Studio
    property bool design_editor: typeof atomic_app === "undefined"

    function get() { return design_editor ? mockAPI : atomic_app }

    property Timer refresh_mockapi: Timer {
        interval: 64
        running: design_editor
        repeat: true
        onTriggered: mockAPI = mockAPI
    }
}
