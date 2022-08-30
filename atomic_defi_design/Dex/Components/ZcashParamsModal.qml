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
    width: 750

    // Inside modal
    Dex.MultipageModalContent {
        titleText: qsTr("%1 Activation Failed!").arg(coin)

        Dex.DefaultText {
            Layout.fillWidth: true
            text: qsTr("To activate ZHTLC coins like %1, you need to download the Zcash Params. This might take a while...").arg(coin)
        }

        ColumnLayout
        {
            Dex.DefaultProgressBar
            {
                id: sprout_proving_key
                label.text: "sprout-proving.key"
                bar_width_pct: 0
                pct_value.text: "0.00 %"
            }

            Dex.DefaultProgressBar
            {
                id: sprout_groth_params
                label.text: "sprout-groth16.params"
                bar_width_pct: 0
                pct_value.text: "0.00 %"
            }
            Dex.DefaultProgressBar
            {
                id: sprout_verifying_key
                label.text: "sprout-verifying.key"
                bar_width_pct: 0
                pct_value.text: "0.00 %"
            }
            Dex.DefaultProgressBar
            {
                id: sapling_output_params
                label.text: "sapling-output.params"
                bar_width_pct: 0
                pct_value.text: "0.00 %"
            }
            Dex.DefaultProgressBar
            {
                id: sapling_spend_params
                label.text: "sapling-spend.params"
                bar_width_pct: 0
                pct_value.text: "0.00 %"
            }

            Component.onCompleted: {
                // Check which files are already downloaded, set bar to 100%
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
                let pct = Dex.General.formatDouble(data.progress * 100, 2)
                switch(data.filename)
                {
                    case "sprout-proving.key.deprecated-sworn-elves":
                        sprout_proving_key.bar_width_pct = pct
                        sprout_proving_key.pct_value.text = pct + "%"
                        break
                    case "sprout-groth16.params":
                        sprout_groth_params.bar_width_pct = pct
                        sprout_groth_params.pct_value.text = pct + "%"
                        break
                    case "sprout-verifying.key":
                        sprout_verifying_key.bar_width_pct = pct
                        sprout_verifying_key.pct_value.text = pct + "%"
                        break
                    case "sapling-output.params":
                        sapling_output_params.bar_width_pct = pct
                        sapling_output_params.pct_value.text = pct + "%"
                        break
                    case "sapling-spend.params":
                        sapling_spend_params.bar_width_pct = pct
                        sapling_spend_params.pct_value.text = pct + "%"
                        break
                }
            }
        }
    }
}
