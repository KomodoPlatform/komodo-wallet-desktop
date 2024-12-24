import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../../../Components"
import "../../../Constants"

MultipageModal
{
    id: root
    width: 1000
    MultipageModalContent
    {
        titleText: qsTr("Selected Order Removed")

        DexLabel
        {
            Layout.fillWidth: true

            wrapMode: Text.WordWrap
            text: qsTr("The selected order does not exist anymore, it might have been matched or cancelled, and no order with a better price is available.\nPlease select a new order.")
        }

        footer:
        [
            DefaultButton
            {
                text: qsTr("OK")
                onClicked: close()
            }
        ]
    }

}
