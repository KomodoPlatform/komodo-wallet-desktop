import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: 400
    // Inside modal
    ColumnLayout {
        width: parent.width

        ModalHeader {
            title: qsTr("Receive")
        }

        // Receive address
        TextAreaWithTitle {
            title: qsTr("Share this address to receive coins")
            field.text: API.get().current_coin_info.address
            field.readOnly: true
            field.wrapMode: TextEdit.NoWrap
            copyable: true
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Close")
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
