import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"

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
        }

        Image {
            Layout.alignment: Qt.AlignHCenter

            source: "image://QZXing/encode/" + current_ticker_infos.address +
                            "?correctionLevel=H" +
                            "&format=qrcode&border=true"
            sourceSize.width: 240
            sourceSize.height: 240
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
        ]
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
