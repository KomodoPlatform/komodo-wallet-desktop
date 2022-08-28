// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// Project Imports
import "../Constants" as Dex
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

        ColumnLayout
        {
            RowLayout
            {
                Dex.DexLabel
                {
                    text: "sprout-groth16.params"
                }
            }
        }


        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
            {
                text: qsTr("Start download")
                onClicked: {
                    Dex.API.app.zcashParamsService.download_zcash_params()
                }
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


    Connections // Catches signals from orders_model.
    {
        target: API.app.download_mgr
        function onDownloadStatusChanged()
        {
            let status = Dex.API.app.download_mgr.download_status
            console.log(status.filename)
            console.log(status.progress)
        }
    }
}
