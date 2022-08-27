// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// Project Imports
import "../Constants"
import "../Components" as Dex
import App 1.0

Dex.MultipageModal {
    id: root
    property string coin: "";

    // Inside modal
    Dex.MultipageModalContent {
        titleText: qsTr("%1 Activation Failed!").arg(coin)

        Dex.DefaultText {
            Layout.preferredHeight: 200
            Layout.fillWidth: true

            text: qsTr("To activate ZHTLC coins like %1, you need to download the Zcash Params. This might take a while...").arg(coin)
        }
        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
            {
                text: qsTr("Start download")
                onClicked: API.app.zcashParamsService.download_zcash_params()
            },
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
            {
                text: qsTr("More Info")
                onClicked: Qt.openUrlExternally("https://www.coinbureau.com/education/zcash-ceremony/")
            },
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
            {
                text: qsTr("Close")
                onClicked: close()
            },
            Item { Layout.fillWidth: true }
        ]
    }
}
