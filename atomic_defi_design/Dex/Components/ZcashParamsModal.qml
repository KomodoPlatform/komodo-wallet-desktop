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
                    text: "sprout-proving.key:"
                }
                Dex.DexLabel
                {
                    id: sprout_proving_key
                    text: "0.00%"
                }
            }
        }

        ColumnLayout
        {
            RowLayout
            {
                Dex.DexLabel
                {
                    text: "sprout-groth16.params:"
                }
                Dex.DexLabel
                {
                    id: sprout_groth_params
                    text: "0.00%"
                }
            }
        }

        ColumnLayout
        {
            RowLayout
            {
                Dex.DexLabel
                {
                    text: "sprout-verifying.key:"
                }
                Dex.DexLabel
                {
                    id: sprout_verifying_key
                    text: "0.00%"
                }
            }
        }

        ColumnLayout
        {
            RowLayout
            {
                Dex.DexLabel
                {
                    text: "sapling-output.params:"
                }
                Dex.DexLabel
                {
                    id: sapling_output_params
                    text: "0.00%"
                }
            }
        }
        ColumnLayout
        {
            RowLayout
            {
                Dex.DexLabel
                {
                    text: "sapling-spend.params:"
                }
                Dex.DexLabel
                {
                    id: sapling_spend_params
                    text: "0.00%"
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
                    Dex.API.app.zcash_params.download_zcash_params()
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

        Connections
        {
            target: Dex.API.app.zcash_params
            function onDownloadStatusChanged()
            {
                let data = JSON.parse(Dex.API.app.zcash_params.get_download_progress())
                switch(data.filename)
                {
                    case "sprout-proving.key.deprecated-sworn-elves":
                        sprout_proving_key.text = Dex.General.formatDouble(data.progress * 100, 2) + "%"
                        break
                    case "sprout-groth16.params":
                        sprout_groth_params.text = Dex.General.formatDouble(data.progress * 100, 2) + "%"
                        break
                    case "sprout-verifying.key":
                        sprout_verifying_key.text = Dex.General.formatDouble(data.progress * 100, 2) + "%"
                        break
                    case "sapling-output.params":
                        sapling_output_params.text = Dex.General.formatDouble(data.progress * 100, 2) + "%"
                        break
                    case "sapling-spend.params":
                        sapling_spend_params.text = Dex.General.formatDouble(data.progress * 100, 2) + "%"
                        break
                }
            }
        }
    }
}
