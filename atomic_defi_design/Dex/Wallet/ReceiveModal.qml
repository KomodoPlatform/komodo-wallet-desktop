import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

MultipageModal
{
    id: root

    function reset() { }

    width: 600

    MultipageModalContent
    {
        titleText: qsTr("Receive")

        TextEditWithTitle
        {
            title: qsTr("Only send %1 to this address:", "TICKER").arg(api_wallet_page.ticker)
            text: current_ticker_infos.address
            label.font.pixelSize: 13
            copy: true
            privacy: true
            onCopyNotificationTitle: qsTr("%1 address".arg(api_wallet_page.ticker))
            onCopyNotificationMsg: qsTr("copied to clipboard.")
        }

        DefaultImage
        {
            Layout.topMargin: 20
            Layout.alignment: Qt.AlignHCenter

            source: current_ticker_infos.qrcode_address

            sourceSize.width: 300
            sourceSize.height: 300
        }

        // Buttons
        footer:
        [
            Item { Layout.fillWidth: true },
            DefaultButton
            {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            },
            Item { Layout.fillWidth: true }
        ]
    }
}
