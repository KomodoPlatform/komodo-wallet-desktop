import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"

BasicModal {
    id: root

    property string coin_type
    property string address

    width: 400

    ModalContent {
        Layout.fillWidth: true
        title: qsTr("Choose a valid ") + coin_type + qsTr(" coin")

        Repeater {
            model: coin_type == "QRC-20" ? API.app.portfolio_pg.global_cfg_mdl.all_qrc20_proxy :
                   coin_type == "ERC-20" ? API.app.portfolio_pg.global_cfg_mdl.all_erc20_proxy :
                   coin_type == "BEP-20" ? API.app.portfolio_pg.global_cfg_mdl.all_bep20_proxy :
                                           API.app.portfolio_pg.global_cfg_mdl.all_smartchains_proxy

            delegate: AddressBookWalletTypeListRow {
                Layout.preferredHeight: height
                Layout.rightMargin: 30
                Layout.fillWidth: true

                ticker: model.ticker
                name: model.name

                onClicked: {
                    trySend(model.ticker, address)
                    close()
                }
            }
        }
    }
}
