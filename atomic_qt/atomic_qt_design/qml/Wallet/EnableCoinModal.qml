import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Inside modal
    ColumnLayout {
        DefaultText {
            text: qsTr("Enable coins")
            font.pointSize: Style.textSize2
        }

        DefaultText {
            text: qsTr("...coins will be here...")
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Close")
                onClicked: enable_coin_modal.close()
            }
            Button {
                text: qsTr("Enable")
                onClicked: console.log(JSON.stringify(API.get().enableable_coins))
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
