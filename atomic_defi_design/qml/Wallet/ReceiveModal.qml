import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    function reset() {

    }

    width: 400
    // Inside modal
    ColumnLayout {
        width: parent.width

        ModalHeader {
            title: API.get().settings_pg.empty_string + (qsTr("Receive"))
        }

        // Receive address
        TextAreaWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Share this address to receive coins"))
            field.text: API.get().settings_pg.empty_string + (current_ticker_infos.address)
            field.readOnly: true
            field.wrapMode: TextEdit.NoWrap
            copyable: true
        }

        Image{
            Layout.alignment: Qt.AlignHCenter

            source: "image://QZXing/encode/" + current_ticker_infos.address +
                            "?correctionLevel=H" +
                            "&format=qrcode&border=true"
            sourceSize.width: 240
            sourceSize.height: 240
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
