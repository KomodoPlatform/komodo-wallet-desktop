pragma Singleton
import QtQuick 2.10

QtObject {
    // Mock API
    property string saved_seed
    property string saved_password
    property var mockAPI: ({
        balance_fiat_all: "12345678.90",

        fiat: "USD",

        current_coin_info: {"objectName":"","ticker":"MORTY","balance":"18.20118151","address":"RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","fiat_amount":"0.00","explorer_url":"https://morty.kmd.dev/","transactions":[{"objectName":"","received":true,"blockheight":265534,"confirmations":5298,"amount":"7.49999","amount_fiat":"0.00","date":"31. Jan 2020 09:08","tx_hash":"23f575a9b93a8149eb87b7a86675485ba646ab34f510ec5a26d4fc6ceee19e46","fees":"0.00001","to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"from":["bJPAVNUbZw9jhy5W2xd2WDe4RDpD2QM9Gw"]},{"objectName":"","received":false,"blockheight":265467,"confirmations":5365,"amount":"3.00001","amount_fiat":"0.00","date":"31. Jan 2020 08:03","tx_hash":"68f688d063df2e0464ead45a031771ba5125f2661dc0504274bcdb74f42e3d36","fees":"0.00001","to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","bCk3peTFj3qf1w6AzfLscfxPWyzcwZdXHK"],"from":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"]},{"objectName":"","received":true,"blockheight":230579,"confirmations":40253,"amount":"13.70120151","amount_fiat":"0.00","date":" 7. Jan 2020 10:31","tx_hash":"9479a455413dbb8f57fad7504d360cb66e984a61eb55eca27e9544b11368d13c","fees":"0.00001","to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"from":["RP5Q1aPXJvNzSvYSfumw3fK3G1UqfHgs63"]}]},

        enabled_coins: [
           { ticker: "RICK", name: "Rick" },
           { ticker: "MORTY", name: "Morty" },
           { ticker: "BTC", name: "Bitcoin" },
        ],

        enableable_coins: [
           { ticker: "KMD", name: "Komodo" },
           { ticker: "CHIPS", name: "Chips" }
        ],

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

        login: (password) => {
            console.log("Logging in with password:" + password)

            const correct = password === saved_password

            if(correct) initialize_mm2.running = true

            return correct
        },

        create: (password, seed) => {
            console.log("Creating the seed with password:")
            console.log(seed)
            console.log(password)

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

        place_sell_order: (base, rel, price, volume) => {
            console.log(`Selling ${volume} ${base} for ${price} ${rel} each`)

            return true
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
               case "BTC": return "5.555"
               case "KMD": return "5.555"
               case "CHIPS": return "5.555"
               case "RICK": return "3.33"
               case "MORTY": return "5.555"
            }
        },

        get_orderbook: () => {
            return {"objectName":"","rel":"KMD","base":"BTC","bids":[{"objectName":"","price":"13464.38669719","maxvolume":"11532.93309343"},{"objectName":"","price":"14443466.19983841","maxvolume":"96666670.24104699"},{"objectName":"","price":"13466.19983841","maxvolume":"970.24104699"},{"objectName":"","price":"13466.19983841","maxvolume":"970.24104699"},{"objectName":"","price":"13326.22601279","maxvolume":"3421.7998824"},{"objectName":"","price":"13326.22601279","maxvolume":"3421.7998824"},{"objectName":"","price":"14705.88235294","maxvolume":"98"},{"objectName":"","price":"10559","maxvolume":"82.3602"}],"asks":[{"objectName":"","price":"17857.14285714","maxvolume":"0.01096449"},{"objectName":"","price":"14443466.19983841","maxvolume":"96666670.24104699"},{"objectName":"","price":"14013.43345341","maxvolume":"1.6377538"}]}
        },

        set_current_orderbook: (base, rel) => {
            console.log("Setting current orderbook: " + base + " - " + rel)
        },

       cancel_order: (order_id) => {

      },

       cancel_all_orders: () => {

      },

        get_my_orders: () => {
               return {
                   "BTC": {
                     "orders": {
                       "maker_orders": [
                         {
                           "rel": "KMD",
                           "base": "BTC",
                           "date": "19 Janvier 2020",
                           "cancellable": true,
                           "base_amount": "1",
                           "rel_amount": "1",
                           "order_id": "4321"
                         },
                       {
                         "rel": "KMD",
                         "base": "BTC",
                         "date": "19 Janvier 2020",
                         "cancellable": true,
                         "base_amount": "1",
                         "rel_amount": "1",
                         "order_id": "4321"
                       }
                       ],
                       "taker_orders": [
                         {
                           "rel": "ETH",
                           "base": "BTC",
                           "date": "20 Janvier 2020",
                           "cancellable": true,
                           "base_amount": "1",
                           "rel_amount": "1",
                           "order_id": "1234"
                         },
                                                   {
                                                     "rel": "ETH",
                                                     "base": "BTC",
                                                     "date": "20 Janvier 2020",
                                                     "cancellable": true,
                                                     "base_amount": "1",
                                                     "rel_amount": "1",
                                                     "order_id": "1234"
                                                   },
                                                   {
                                                     "rel": "ETH",
                                                     "base": "BTC",
                                                     "date": "20 Janvier 2020",
                                                     "cancellable": true,
                                                     "base_amount": "1",
                                                     "rel_amount": "1",
                                                     "order_id": "1234"
                                                   },
                                                   {
                                                     "rel": "ETH",
                                                     "base": "BTC",
                                                     "date": "20 Janvier 2020",
                                                     "cancellable": true,
                                                     "base_amount": "1",
                                                     "rel_amount": "1",
                                                     "order_id": "1234"
                                                   },
                                                   {
                                                     "rel": "ETH",
                                                     "base": "BTC",
                                                     "date": "20 Janvier 2020",
                                                     "cancellable": true,
                                                     "base_amount": "1",
                                                     "rel_amount": "1",
                                                     "order_id": "1234"
                                                   },
                                                   {
                                                     "rel": "ETH",
                                                     "base": "BTC",
                                                     "date": "20 Janvier 2020",
                                                     "cancellable": true,
                                                     "base_amount": "1",
                                                     "rel_amount": "1",
                                                     "order_id": "1234"
                                                   },
                                                   {
                                                     "rel": "ETH",
                                                     "base": "BTC",
                                                     "date": "20 Janvier 2020",
                                                     "cancellable": true,
                                                     "base_amount": "1",
                                                     "rel_amount": "1",
                                                     "order_id": "1234"
                                                   }
                       ]
                     }
                   }
                 }
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
