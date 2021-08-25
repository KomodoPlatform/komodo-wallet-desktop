import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"
import ".."

import "Orders/"

DefaultModal {
    id: root

    width: API.app.trading_pg.preimage_rpc_busy? 300 : 1100

    onOpened: reset()

    function reset() {
        API.app.trading_pg.determine_fees()

    }
    Connections {
        target: API.app.trading_pg
        function onFeesChanged() {
            console.log(JSON.stringify(API.app.trading_pg.fees))
        }
    }
    Connections {
        target: API.app.trading_pg
        function onPreImageRpcStatusChanged(){
            console.log(API.app.trading_pg.preimage_rpc_busy)
        }
    }
}
