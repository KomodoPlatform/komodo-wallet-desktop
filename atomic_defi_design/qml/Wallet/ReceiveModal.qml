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
        title: API.app.settings_pg.empty_string + (qsTr("Receive"))

        // Receive address
        TextAreaWithTitle {
            title: API.app.settings_pg.empty_string + (qsTr("Share this address to receive coins"))
            field.text: API.app.settings_pg.empty_string + (current_ticker_infos.address)
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
                text: API.app.settings_pg.empty_string + (qsTr("Close"))
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
