pragma Singleton
import QtQuick 2.10

QtObject {
    // Mock API
    property string saved_seed
    property string saved_password
    property var mockAPI: ({

        fiat: "USD",

        current_coin_info: {
            address: "RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2",
            ticker: "RICK",
            balance: "3.33",
            fiat_amount: "0",
            explorer_url: "https://rick.explorer.dexstats.info/",
            transactions: [
                { received: true, amount: "7.777", amount_fiat: "4.24", date: "6. Jan 2020 13:37" },
                { received: false, amount: "4.444", amount_fiat: "2.73", date: "1. Jan 2020 13:38" },
                { received: false, amount: "0.13371337", amount_fiat: "0.72233", date: "15. May 2019 13:38" },
                { received: true, amount: "61.232553", amount_fiat: "32.24", date: "2. Feb 2019 17:37" },
                { received: false, amount: "553.42223522", amount_fiat: "335.31", date: "17. Oct 1963 14:26" }
            ]
        },

        enabled_coins: [
           { ticker: "RICK", name: "Rick" },
           { ticker: "MORTY", name: "Morty" },
        ],

        enableable_coins: [
           { ticker: "BTC", name: "Bitcoin" },
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

        prepare_send_coin: (address, amount, max=true) => {
           console.log("Preparing to send " + amount + " to " + address)

           return {
               has_error: false,
               error_message: "",
               tx_hex: "abcdefghijklmnopqrstuvwxyz",
               date: "17. Oct 1963 14:26"
           }
        },

       send: (tx_hex) => {
          console.log("Sending tx hex:" + tx_hex)

          return "abcdefghijklmnopqrstuvwxyz"
       },

       on_gui_enter_dex: () => {
           console.log("on_gui_enter_dex")
       },

       on_gui_leave_dex: () => {
           console.log("on_gui_leave_dex")
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
