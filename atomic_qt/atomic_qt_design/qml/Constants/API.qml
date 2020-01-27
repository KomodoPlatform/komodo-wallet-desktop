pragma Singleton
import QtQuick 2.10

QtObject {
    // Mock API
    property string saved_seed
    property string saved_password
    property var mockAPI: ({

        fiat: "USD",

        current_coin_info: {
            ticker: "RICK",
            balance: "3.33",
            fiat_amount: "0",
            transactions: [
                { received: true, amount: "7.777 KMD", amount_fiat: "4.24 EUR", date: "6. Jan 2020 13:37" },
                { received: false, amount: "4.444 KMD", amount_fiat: "2.73 EUR", date: "1. Jan 2020 13:38" },
                { received: false, amount: "0.13371337 KMD", amount_fiat: "0.72233 EUR", date: "15. May 2019 13:38" },
                { received: true, amount: "61.232553 KMD", amount_fiat: "32.24 EUR", date: "2. Feb 2019 17:37" },
                { received: false, amount: "553.42223522 KMD", amount_fiat: "335.31 EUR", date: "17. Oct 1963 14:26" }
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

            return password === saved_password
        },

        create: (password, seed) => {
            console.log("Creating the seed with password:")
            console.log(seed)
            console.log(password)

            saved_seed = seed
            saved_password = password

            return saved_password !== ''
        }
    })

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
