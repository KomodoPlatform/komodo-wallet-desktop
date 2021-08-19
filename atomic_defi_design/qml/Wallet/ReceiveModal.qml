import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

BasicModal {
    id: root

    function reset() {

    }

    width: 500

    ModalContent {
        title: qsTr("Receive")

        // Receive address
        TextAreaWithTitle {
            title: qsTr("Only send %1 to this address", "TICKER").arg(api_wallet_page.ticker)
            field.text: current_ticker_infos.address
            field.readOnly: true
            field.wrapMode: TextEdit.NoWrap
            copyable: true
            onCopied: {
                app.notifyCopy(qsTr("%1 address").arg(api_wallet_page.ticker), qsTr("copied to clipboard"))
            }
        }

        Image {
            Layout.alignment: Qt.AlignHCenter

            source: current_ticker_infos.qrcode_address

            sourceSize.width: 200
            sourceSize.height: 200
        }

        // Buttons
        footer: [
            Item {
                    Layout.fillWidth: true
            },
            DexAppButton {
                text: qsTr("Close")
                leftPadding: 40
                rightPadding: 40
                radius: 18
                onClicked: root.close()
            }
        ]
    }
}
