// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// Project Imports
import "../Constants"
import App 1.0

MultipageModal {
    id: root
    property string coin: "";

    // Inside modal
    MultipageModalContent {
        titleText: qsTr("%1 Activation Failed!").arg(coin)

        DefaultText {
            Layout.preferredHeight: 200
            Layout.fillWidth: true

            text: qsTr("To activate ZHTLC coins like %1, you need to download the Zcash Params. This might take a while...").arg(coin)
        }
    }
}
