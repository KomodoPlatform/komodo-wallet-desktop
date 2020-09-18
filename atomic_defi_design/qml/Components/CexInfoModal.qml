import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"
import ".."

BasicModal {
    id: root

    // Inside modal
    ModalContent {
        title: API.app.settings_pg.empty_string + (General.cex_icon + " " + qsTr("Market Data"))

        DefaultText {
            Layout.fillWidth: true

            text_value: API.app.settings_pg.empty_string + (qsTr('Market data (prices, charts, etc.) marked with the ⓘ icon originates from third-party sources.<br><br>Data is sourced via <a href="https://bandprotocol.com/">Band Decentralized Oracle</a> and <a href="https://coinpaprika.com">Coinpaprika</a>.<br><br><b>Oracle Supported Pairs:</b><br>%1<br><br><b>Last reference (Band Oracle):</b><br><a href="%2">%2</a>')
                                                                .arg(API.app.portfolio_pg.oracle_price_supported_pairs.join(', '))
                                                                .arg(API.app.portfolio_pg.oracle_last_price_reference))
            wrapMode: Text.WordWrap
        }
    }
}
