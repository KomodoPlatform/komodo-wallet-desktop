// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

// Project Imports
import "../Constants"
import App 1.0

MultipageModal {
    id: root

    // Inside modal
    MultipageModalContent {
        titleText: General.cex_icon + " " + qsTr("Minimum Trading Amount")

        DexLabel {
            //Layout.preferredHeight: 200
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr('the minimum amount of %1 coin available for the order; the min_volume must be greater than or equal to %2; it must be also less or equal than volume param; default is %3')
                            .arg(API.app.trading_pg.market_pairs_mdl.left_selected_coin)
                            .arg(API.app.trading_pg.orderbook.current_min_taker_vol)
                            .arg(API.app.trading_pg.orderbook.current_min_taker_vol)
        }
    }
}
