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
        titleText: General.cex_icon + " " + qsTr("How do I calculate gas?")

        DexLabel {
            Layout.fillWidth: true

            text: qsTr('Gas is measured in gwei. Gwei is just a unit of Ether, and is equal to 0.000000001 ETH (or the equivalent platform coin such as AVAX or BNB). The gas price varies over time depending on network congestion.')
        }
        DexLabel {
            Layout.fillWidth: true

            text: qsTr('The gas limit is how many units of gas (maximum) you allocate to pay for a transaction. The gas required depending on the size of the transaction & data being transmitted.')
        }
        DexLabel {
            Layout.fillWidth: true

            text: qsTr('A standard transaction not involving contracts uses 21,000 gas units, with any of the limit remaining returned to the source address.')
        }
        DexLabel {
            Layout.fillWidth: true

            text: qsTr('Transactions involving contracts may result in the whole limit being consumed, so be careful not to set it too high.')
        }
        DexLabel {
            Layout.fillWidth: true

            text: qsTr('For more information, read the article at <a href="https://support.mycrypto.com/how-to/sending/how-to-know-what-gas-limit-to-use">https://support.mycrypto.com/how-to/sending/how-to-know-what-gas-limit-to-use</a>')
        }
    }
}
