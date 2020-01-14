pragma Singleton
import QtQuick 2.10

QtObject {
    function getAtomicApp() {
        const design_editor = typeof atomic_app === "undefined"
        return !design_editor ? atomic_app : mockAPI()
    }

    // Mock variables
    property bool seed_exists: false

    // Mock API
    function mockAPI() {
        return {
            first_run: () => {
                return !seed_exists
            },

            get_mnemonic: () => {
                return "this is a test seed gossip rubber flee just connect manual any salmon limb suffer now turkey essence naive daughter system begin quantum page"
            },

            login: (password) => {
                console.log("Logging in with password:" + password)
                return true
            },

            create: (password, seed) => {
                console.log("Creating the seed with password:")
                console.log(seed)
                console.log(password)

                seed_exists = true

                return seed_exists
            },

            enabled_coins: [
                { ticker: "BTC", name: "Bitcoin" },
                { ticker: "KMD", name: "Komodo" },
                { ticker: "RICK", name: "Rick" },
                { ticker: "MORTY", name: "Morty" },
            ],
        }
    }
}
