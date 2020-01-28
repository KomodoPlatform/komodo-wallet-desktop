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

    // Inside modal
    ColumnLayout {
        // Title
        DefaultText {
            text: qsTr("Send")
            font.pointSize: Style.textSize2
        }

        // Send address
        TextAreaWithTitle {
            title: qsTr("Recipient's address")
            field.placeholderText: qsTr("Enter address of the recipient")
            field.wrapMode: TextEdit.NoWrap
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
