pragma Singleton
import QtQuick 2.10

QtObject {
    // Mock API
    property string saved_seed
    property string saved_password
    property var mockAPI: ({
        // Signals
        myOrdersUpdated: {
           connect: (func) => { console.log("Connecting function") }
       },

        // Other
        wallet_default_name: "",

        balance_fiat_all: "12345678.90",

        fiat: "USD",

        current_coin_info: {"objectName":"", "is_claimable": true, "minimal_balance_for_asking_rewards": "10", "ticker":"MORTY", "balance":"18.20118151","address":"RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","fiat_amount":"0.00","explorer_url":"https://morty.kmd.dev/","transactions":[{"objectName":"","received":true,"blockheight":265534,"confirmations":5298,"amount":"7.49999","amount_fiat":"0.00","date":"31. Jan 2020 09:08","tx_hash":"23f575a9b93a8149eb87b7a86675485ba646ab34f510ec5a26d4fc6ceee19e46","fees":"0.00001","to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"from":["bJPAVNUbZw9jhy5W2xd2WDe4RDpD2QM9Gw"]},{"objectName":"","received":false,"blockheight":265467,"confirmations":5365,"amount":"3.00001","amount_fiat":"0.00","date":"31. Jan 2020 08:03","tx_hash":"68f688d063df2e0464ead45a031771ba5125f2661dc0504274bcdb74f42e3d36","fees":"0.00001","to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","bCk3peTFj3qf1w6AzfLscfxPWyzcwZdXHK"],"from":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"]},{"objectName":"","received":true,"blockheight":230579,"confirmations":40253,"amount":"13.70120151","amount_fiat":"0.00","date":" 7. Jan 2020 10:31","tx_hash":"9479a455413dbb8f57fad7504d360cb66e984a61eb55eca27e9544b11368d13c","fees":"0.00001","to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"from":["RP5Q1aPXJvNzSvYSfumw3fK3G1UqfHgs63"]}]},

        get_coin_info: (ticker) => {
            const data = { "MORTY": { explorer_url: "https://morty.kmd.dev/" }, "RICK": { explorer_url: "https://rick.kmd.dev/" }, "KMD": { explorer_url: "https://kmdexplorer.io/" } }
            return data[ticker]
        },

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
       cancel_all_orders_by_ticker: (ticker) => {

      },

        get_my_orders: () => { return {"BTC":{"objectName":"","taker_orders":[],"maker_orders":[]},"CHIPS":{"objectName":"","taker_orders":[],"maker_orders":[]},"ETH":{"objectName":"","taker_orders":[],"maker_orders":[]},"KMD":{"objectName":"","taker_orders":[],"maker_orders":[]},"MORTY":{"objectName":"","taker_orders":[],"maker_orders":[{"objectName":"","price":"","date":"2020-02-07 09:31:50.430","base":"MORTY","rel":"RICK","cancellable":true,"am_i_maker":true,"base_amount":"7","rel_amount":"861","uuid":"dc13abf1-3262-4dcb-9891-e04d4cb63d33"},{"objectName":"","price":"","date":"2020-02-07 09:32:03.124","base":"RICK","rel":"MORTY","cancellable":true,"am_i_maker":true,"base_amount":"10","rel_amount":"50","uuid":"7cab68d5-2de5-4c29-980c-1a72620f38bf"},{"objectName":"","price":"","date":"2020-02-07 09:32:22.688","base":"RICK","rel":"MORTY","cancellable":true,"am_i_maker":true,"base_amount":"3","rel_amount":"9","uuid":"db5059db-94da-4a1e-b2e1-cef603f796c5"}]},"RICK":{"objectName":"","taker_orders":[],"maker_orders":[{"objectName":"","price":"","date":"2020-02-07 09:31:50.430","base":"MORTY","rel":"RICK","cancellable":true,"am_i_maker":true,"base_amount":"7","rel_amount":"861","uuid":"dc13abf1-3262-4dcb-9891-e04d4cb63d33"},{"objectName":"","price":"","date":"2020-02-07 09:32:03.124","base":"RICK","rel":"MORTY","cancellable":true,"am_i_maker":true,"base_amount":"10","rel_amount":"50","uuid":"7cab68d5-2de5-4c29-980c-1a72620f38bf"},{"objectName":"","price":"","date":"2020-02-07 09:32:22.688","base":"RICK","rel":"MORTY","cancellable":true,"am_i_maker":true,"base_amount":"3","rel_amount":"9","uuid":"db5059db-94da-4a1e-b2e1-cef603f796c5"}]}} },

       is_claiming_ready: (ticker) => { return true },
       claim_rewards: (ticker) => { return {"objectName":"","has_error":false,"error_message":"","tx_hex":"0400008085202f8902755d841b4ecff907a7f49633af202e29363e3ed71fdc1918c5541648fc20ff36010000006a4730440220418adfffe0bc798af13d0241e6e45c4a2d4080a3dcdd90b497c31d155a52666c0220690ca5e11d9ddd681aae7a2eca137104701621961a5ca21bdb593c8cc6d20198012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff2de18d8aefe1967610ac76547ac70a56a724b25cb855e1451f63a327a3976107000000006b483045022100d49b5a5d6a5b9fcb368208cb1fb29eeed0fe864d6ef62d78e82f1fdc150d115d022078e119b15e63a7b1e5f927d8497d2269b91dddb42de5ea18d74662ecbd2558a7012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff0108365b3f000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88ac8dcd3e5e000000000000000000000000000000","date":" 8. Feb 2020 03:15","balance_change":"0.00147216","fees":"0.00001","explorer_url":"https://kmdexplorer.io/"} },

       send_rewards: (tx_hex) => {
          console.log("Sending tx hex:" + tx_hex)

          return "abcdefghijklmnopqrstuvwxyz"
       },

       get_recent_swaps: () => {
           return {"769e6d7d-a3bd-404e-a9d1-bf6983b09f88":{"error_events":["StartFailed","NegotiateFailed","TakerFeeSendFailed","MakerPaymentValidateFailed","MakerPaymentWaitConfirmFailed","TakerPaymentTransactionFailed","TakerPaymentWaitConfirmFailed","TakerPaymentDataSendFailed","TakerPaymentWaitForSpendFailed","MakerPaymentSpendFailed","TakerPaymentWaitRefundStarted","TakerPaymentRefunded","TakerPaymentRefundFailed"],"events":[{"data":{"lock_duration":7800,"maker":"15d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732","maker_amount":"0.06685","maker_coin":"RICK","maker_coin_start_block":281506,"maker_payment_confirmations":1,"maker_payment_wait":1581588488,"my_persistent_pub":"03f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5","started_at":1581585368,"taker_amount":"0.1337","taker_coin":"MORTY","taker_coin_start_block":283485,"taker_payment_confirmations":1,"taker_payment_lock":1581593168,"uuid":"769e6d7d-a3bd-404e-a9d1-bf6983b09f88"},"human_timestamp":"2020-02-13    09:16:08.936","state":"Started"},{"data":{"maker_payment_locktime":1581600968,"maker_pubkey":"0315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732","secret_hash":"71ee7f691bb06400775a5192f04a14674c5bf74d"},"human_timestamp":"2020-02-13    09:17:09.750","state":"Negotiated"},{"data":{"block_height":0,"coin":"MORTY","fee_details":{"amount":"0.00001"},"from":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"internal_id":"6dd019b060fe3ae0c86abfc49c260fe5790deb9d1b8367944b3d00c302592f3a","my_balance_change":"-0.00018207","received_by_me":"0.99981793","spent_by_me":"1","timestamp":0,"to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","RThtXup6Zo7LZAi8kRWgjAyi1s4u6U9Cpf"],"total_amount":"1","tx_hash":"6dd019b060fe3ae0c86abfc49c260fe5790deb9d1b8367944b3d00c302592f3a","tx_hex":"0400008085202f8901ad09eade95546f96645cda147e361ba1282860a0380a41daa5053256ec9e80c9000000006b483045022100c947c60b1f81fe3f2e839151e1dcc1db632252b69fcf148dbb5f51bb9922d50b02203a6689cbe63de6cf662126e49413dfbb99b8ed78c7aec21fb89786e9efff152b012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff0237430000000000001976a914ca1e04745e8ca0c60d8c5881531d51bec470743f88ace199f505000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88ac1514455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    09:17:15.386","state":"TakerFeeSent"},{"data":{"block_height":0,"coin":"RICK","fee_details":{"amount":"0.00001"},"from":["RB8yufv3YTfdzYnwz5paNnnDynGJG6WsqD"],"internal_id":"a197e341f107e51b2614dadfc12ec7d60047a22d94120e8660394f8a26cbcd5e","my_balance_change":"0","received_by_me":"0","spent_by_me":"0","timestamp":0,"to":["RB8yufv3YTfdzYnwz5paNnnDynGJG6WsqD","bDMc2irZGnr8ss68Gx3LFoi7Rcw4eisf9E"],"total_amount":"0.29999","tx_hash":"a197e341f107e51b2614dadfc12ec7d60047a22d94120e8660394f8a26cbcd5e","tx_hex":"0400008085202f8901a2ad998c61defe3f11a8f937eb34ae0a322db04313920506888f72f1d9bd31c6000000006b483045022100d8754472da118d9fff4370adf778f36e83d627e23e863d2c848964b50cd1c4bc02201f06ea7a314e8875c25336b3d23da8c4fc8e645bd386a38d707028df3392736301210315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732ffffffff02480166000000000017a91406df1d952e4a119722e9b046ea03ecb21d29ee7b8768ba6301000000001976a9141462c3dd3f936d595c9af55978003b27c250441f88ac2e14455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    09:17:56.385","state":"MakerPaymentReceived"},{"human_timestamp":"2020-02-13    09:17:56.387","state":"MakerPaymentWaitConfirmStarted"},{"human_timestamp":"2020-02-13    09:18:12.003","state":"MakerPaymentValidatedAndConfirmed"},{"data":{"block_height":0,"coin":"MORTY","fee_details":{"amount":"0.00001"},"from":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"internal_id":"eae60e81b21577136edd9a6c28f70603d7acd6d7331253dc24f993ec38fe98a5","my_balance_change":"-0.13371","received_by_me":"0.86509794","spent_by_me":"0.99880794","timestamp":0,"to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","bX74z9w8ncS9zPtUsLVSLFPTJe8egWazH4"],"total_amount":"0.99880794","tx_hash":"eae60e81b21577136edd9a6c28f70603d7acd6d7331253dc24f993ec38fe98a5","tx_hex":"0400008085202f8901901b3afd7a3e291f7abf930c7bd60435a1a622de6d7906166e06840567234530010000006a473044022044bc850ecb0926da30c70fe673cbca2180c948b7176b6d91b29c813b0622c42d0220100da5a7b6f167008266204f16cf9b9cb7f9c3c20296247df08275b9587d1fc6012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff029002cc000000000017a914c991a449b651d38f99f5319252653a15d7d3d27487e2082805000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88ac5414455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    09:18:15.432","state":"TakerPaymentSent"},{"data":{"secret":"fa09b5576f5f3832ff57f07f74f9278ac5fb1bd080035ed7ce90762d56cd15cb","transaction":{"block_height":0,"coin":"MORTY","fee_details":{"amount":"0.00001"},"from":["bX74z9w8ncS9zPtUsLVSLFPTJe8egWazH4"],"internal_id":"baf5e6f8e0bdcf77a5c73cff15afeaef9dd7411d6aeafa0e12d11fe44794b648","my_balance_change":"0","received_by_me":"0","spent_by_me":"0","timestamp":0,"to":["RB8yufv3YTfdzYnwz5paNnnDynGJG6WsqD"],"total_amount":"0.1337","tx_hash":"baf5e6f8e0bdcf77a5c73cff15afeaef9dd7411d6aeafa0e12d11fe44794b648","tx_hex":"0400008085202f8901a598fe38ec93f924dc531233d7d6acd70306f7286c9add6e137715b2810ee6ea00000000d74730440220452b4d9b89fb786222ba1142eb772e6bf2ad86b5ee36772549c85364e09005b802203951a81ddae1ce1914309cb2c0d2a36735d1ab8469a49377724ebc003932082f0120fa09b5576f5f3832ff57f07f74f9278ac5fb1bd080035ed7ce90762d56cd15cb004c6b63045032455eb1752103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ac6782012088a91471ee7f691bb06400775a5192f04a14674c5bf74d88210315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732ac68ffffffff01a8fecb00000000001976a9141462c3dd3f936d595c9af55978003b27c250441f88aca606455e000000000000000000000000000000"}},"human_timestamp":"2020-02-13    09:19:58.103","state":"TakerPaymentSpent"},{"data":{"block_height":0,"coin":"RICK","fee_details":{"amount":"0.00001"},"from":["bDMc2irZGnr8ss68Gx3LFoi7Rcw4eisf9E"],"internal_id":"8bf5ef87627445df7af35e89055be027063ac048fd585d412bb657d572a41392","my_balance_change":"0.06684","received_by_me":"0.06684","spent_by_me":"0","timestamp":0,"to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"total_amount":"0.06685","tx_hash":"8bf5ef87627445df7af35e89055be027063ac048fd585d412bb657d572a41392","tx_hex":"0400008085202f89015ecdcb268a4f3960860e12942da24700d6c72ec1dfda14261be507f141e397a100000000d8483045022100fa99cd00ec5edb06ccac523428b56c214cb0878d501f6196c2688821184fe842022051338d433e94d05d5848ac41fc50fe5ccf38a481b387b0bc67dac804e33323d20120fa09b5576f5f3832ff57f07f74f9278ac5fb1bd080035ed7ce90762d56cd15cb004c6b6304c850455eb175210315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732ac6782012088a91471ee7f691bb06400775a5192f04a14674c5bf74d882103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ac68ffffffff0160fd6500000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88acae06455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    09:19:59.920","state":"MakerPaymentSpent"}],"maker_amount":"0.06685","maker_coin":"RICK","my_info":{"my_amount":"0.1337","my_coin":"MORTY","other_amount":"0.06685","other_coin":"RICK","started_at":1581585368},"taker_amount":"0.1337","taker_coin":"MORTY","type":"Taker","swap_id":"769e6d7d-a3bd-404e-a9d1-bf6983b09f88"},"976ff2c3-9352-4c3e-be1e-92d5ab8d9bb2":{"error_events":["StartFailed","NegotiateFailed","TakerFeeSendFailed","MakerPaymentValidateFailed","MakerPaymentWaitConfirmFailed","TakerPaymentTransactionFailed","TakerPaymentWaitConfirmFailed","TakerPaymentDataSendFailed","TakerPaymentWaitForSpendFailed","MakerPaymentSpendFailed","TakerPaymentWaitRefundStarted","TakerPaymentRefunded","TakerPaymentRefundFailed"],"events":[{"data":{"lock_duration":7800,"maker":"15d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732","maker_amount":"0.3885","maker_coin":"RICK","maker_coin_start_block":281506,"maker_payment_confirmations":1,"maker_payment_wait":1581588526,"my_persistent_pub":"03f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5","started_at":1581585406,"taker_amount":"0.777","taker_coin":"MORTY","taker_coin_start_block":283487,"taker_payment_confirmations":1,"taker_payment_lock":1581593206,"uuid":"976ff2c3-9352-4c3e-be1e-92d5ab8d9bb2"},"human_timestamp":"2020-02-13    09:16:46.436","state":"Started"},{"data":{"maker_payment_locktime":1581601005,"maker_pubkey":"0315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732","secret_hash":"245203849c6bb40a8fce31154e8851cce6c6cdb2"},"human_timestamp":"2020-02-13    09:17:47.109","state":"Negotiated"},{"data":{"block_height":0,"coin":"MORTY","fee_details":{"amount":"0.00001"},"from":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"internal_id":"304523670584066e1606796dde22a6a13504d67b0c93bf7a1f293e7afd3a1b90","my_balance_change":"-0.00100999","received_by_me":"0.99880794","spent_by_me":"0.99981793","timestamp":0,"to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","RThtXup6Zo7LZAi8kRWgjAyi1s4u6U9Cpf"],"total_amount":"0.99981793","tx_hash":"304523670584066e1606796dde22a6a13504d67b0c93bf7a1f293e7afd3a1b90","tx_hex":"0400008085202f89013a2f5902c3003d4b9467831b9deb0d79e50f269cc4bf6ac8e03afe60b019d06d010000006b483045022100dd00e848180dc32ca7d74e5a7031a7cb5a60cbc307c1900a1cf1a5a33eb72eae02203798f8db08d4b0fdb9953daa93755dd90e20d6cf0a463e5797b9d9d0156735d1012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff029f860100000000001976a914ca1e04745e8ca0c60d8c5881531d51bec470743f88ac5a0ff405000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88ac3b14455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    09:17:51.553","state":"TakerFeeSent"},{"data":{"block_height":0,"coin":"RICK","fee_details":{"amount":"0.00001"},"from":["RB8yufv3YTfdzYnwz5paNnnDynGJG6WsqD"],"internal_id":"b3b76eca9d323744c1b35b88c397d01984d807c7c697717a553fe0ba23cf27d3","my_balance_change":"0","received_by_me":"0","spent_by_me":"0","timestamp":0,"to":["RB8yufv3YTfdzYnwz5paNnnDynGJG6WsqD","bRriAAtNJ9Ehvo3aRYNTv3wbGa2nu4Dp2m"],"total_amount":"1.23312","tx_hash":"b3b76eca9d323744c1b35b88c397d01984d807c7c697717a553fe0ba23cf27d3","tx_hex":"0400008085202f89025ecdcb268a4f3960860e12942da24700d6c72ec1dfda14261be507f141e397a1010000006a47304402203fb40e3871848b268cc37cad1439e5fe6fcec3963394d11cf4cfc45f367fd69b022045963ac14c09558669d2624a6705a8c17b4fc49746f79ec88b33a33506c39bf901210315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732ffffffff6857d34e9dde8fac941cfea3da5a90adb7b3479f80d38ee69add08b2d68a820a000000006a47304402202181c84c5064474be6ee104af713539730f0846d70d10f97f1c476e660de923f02201d5cc32c0efc20b02c3abe08e49e2fe403a39f099e874db249f5ac4639058c8801210315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732ffffffff02d0cd50020000000017a9149001cdb94cf822429108b6c58b7f6b95f903983187c8c50805000000001976a9141462c3dd3f936d595c9af55978003b27c250441f88ac5214455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    09:18:35.179","state":"MakerPaymentReceived"},{"human_timestamp":"2020-02-13    09:18:35.181","state":"MakerPaymentWaitConfirmStarted"},{"human_timestamp":"2020-02-13    09:27:38.270","state":"MakerPaymentValidatedAndConfirmed"},{"data":{"block_height":0,"coin":"MORTY","fee_details":{"amount":"0.00001"},"from":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"internal_id":"a0119225328c3f406d6f1d1abfea69c46d28951c4a87cec113fc90bd300f73c5","my_balance_change":"-0.77701","received_by_me":"0.08808794","spent_by_me":"0.86509794","timestamp":0,"to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2","bCpYBxxAYqUCikZEbRmvyoWnXDCswJKCQN"],"total_amount":"0.86509794","tx_hash":"a0119225328c3f406d6f1d1abfea69c46d28951c4a87cec113fc90bd300f73c5","tx_hex":"0400008085202f8901a598fe38ec93f924dc531233d7d6acd70306f7286c9add6e137715b2810ee6ea010000006a473044022041a32b2cff47e328f3ae5e3c269d8c82e4919415fbc7200ad4b4e4c1e10426f202207c4d82308c03a43aa16b5a7e6dd356ebbf781f43fec94cc455588d47e30d7e05012103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ffffffff02a09ba1040000000017a91400ff03c5fac2ee45bb730c6c19bf14660db65f50875a698600000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88ac8a16455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    09:27:45.329","state":"TakerPaymentSent"},{"data":{"secret":"1d89890c00dedaf074f1e1f2f2d1059e6a8b3d5aee2e62af9e353e817e86a8e0","transaction":{"block_height":0,"coin":"MORTY","fee_details":{"amount":"0.00001"},"from":["bCpYBxxAYqUCikZEbRmvyoWnXDCswJKCQN"],"internal_id":"bed2bd160cf3c9a0478b338104fef842e58b0c533625e8485dd74f0ae7e9ac78","my_balance_change":"0","received_by_me":"0","spent_by_me":"0","timestamp":0,"to":["RB8yufv3YTfdzYnwz5paNnnDynGJG6WsqD"],"total_amount":"0.777","tx_hash":"bed2bd160cf3c9a0478b338104fef842e58b0c533625e8485dd74f0ae7e9ac78","tx_hex":"0400008085202f8901c5730f30bd90fc13c1ce874a1c95286dc469eabf1a1d6f6d403f8c32259211a000000000d74730440220753282f4ea3b59d69e2b2e23b4fe74cab7b1c96b4318880bcc42874f18bcd8730220056c17360e23d3b683f4d7b1702d65a11e1f77d9b1526a5ced50c025a1db7ee101201d89890c00dedaf074f1e1f2f2d1059e6a8b3d5aee2e62af9e353e817e86a8e0004c6b63047632455eb1752103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ac6782012088a914245203849c6bb40a8fce31154e8851cce6c6cdb288210315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732ac68ffffffff01b897a104000000001976a9141462c3dd3f936d595c9af55978003b27c250441f88ac3c17455e000000000000000000000000000000"}},"human_timestamp":"2020-02-13    10:30:48.337","state":"TakerPaymentSpent"},{"data":{"block_height":0,"coin":"RICK","fee_details":{"amount":"0.00001"},"from":["bRriAAtNJ9Ehvo3aRYNTv3wbGa2nu4Dp2m"],"internal_id":"930b756ab2d5493719b1d94eaf65498a287af65ec7011a82e0ec0673abd9c310","my_balance_change":"0.38849","received_by_me":"0.38849","spent_by_me":"0","timestamp":0,"to":["RH8WgfYXbeMgF96vCqfKo47TkFApNXkQM2"],"total_amount":"0.3885","tx_hash":"930b756ab2d5493719b1d94eaf65498a287af65ec7011a82e0ec0673abd9c310","tx_hex":"0400008085202f8901d327cf23bae03f557a7197c6c707d88419d097c3885bb3c14437329dca6eb7b300000000d7473044022024e31d930889f1fd4f26a9678da0b0292328dd41380591dc3f6c94893c822bd50220432555c28edfed6d370cef45a2a27f4c0a1ce6935611d6d57666eac396e911f001201d89890c00dedaf074f1e1f2f2d1059e6a8b3d5aee2e62af9e353e817e86a8e0004c6b6304ed50455eb175210315d9c51c657ab1be4ae9d3ab6e76a619d3bccfe830d5363fa168424c0d044732ac6782012088a914245203849c6bb40a8fce31154e8851cce6c6cdb2882103f813f322d82167027f635f08686fdc615f2f98d8f5f49091dafc62d520666aa5ac68ffffffff01e8c95002000000001976a914561ccb4cb9159a1ba1b81c133507ea950e065edc88ac4817455e000000000000000000000000000000"},"human_timestamp":"2020-02-13    10:30:50.171","state":"MakerPaymentSpent"},{"human_timestamp":"2020-02-13    10:30:50.174","state":"Finished"}],"maker_amount":"0.3885","maker_coin":"RICK","my_info":{"my_amount":"0.777","my_coin":"MORTY","other_amount":"0.3885","other_coin":"RICK","started_at":1581585406},"taker_amount":"0.777","taker_coin":"MORTY","type":"Taker","swap_id":"976ff2c3-9352-4c3e-be1e-92d5ab8d9bb2"}}
       },

        refresh_infos: () => {
            console.log("refresh infos!")
        },

        refresh_orders_and_swaps: () => {
            console.log("refresh_orders_and_swaps!")
        },

        get_wallets: () => { return ["encrypted"] }
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
