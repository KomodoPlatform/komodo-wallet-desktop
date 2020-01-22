pragma Singleton
import QtQuick 2.10

QtObject {
    property bool design_editor: typeof atomic_app === "undefined"

    function get() { return !design_editor ? atomic_app : mockAPI }

    Component.onCompleted: refresh_mockapi.running = design_editor
    property Timer refresh_mockapi: Timer {
        interval: 64
        repeat: true
        onTriggered: mockAPI = mockAPI
    }

    // Mock API
    property string saved_seed
    property string saved_password
    property var mockAPI: ({
        current_coin_info: {
            ticker: "MORTY"
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
        },

        enabled_coins: [
            { ticker: "BTC", name: "Bitcoin" },
            { ticker: "KMD", name: "Komodo" },
            { ticker: "RICK", name: "Rick" },
            { ticker: "MORTY", name: "Morty" },
        ],
    })
}
