import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt.labs.platform 1.0

import "../Constants"
import "../Components"

FloatingBackground {
    id: root

    SystemTrayIcon {
        id: tray
        visible: true
        iconSource: General.coinIcon("KMD")
        onMessageClicked: console.log("Message clicked")

        tooltip: qsTr("AtomicDEX Pro")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        DefaultText {
            text_value: API.get().empty_string + (qsTr("Notifications"))
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.pixelSize: Style.textSize3
        }

        HorizontalLine {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
        }

        DefaultButton {
            text: API.get().empty_string + (qsTr("Pop Notification"))
            Layout.alignment: Qt.AlignTop
            onClicked: {
                console.log("System tray is " + (tray.available ? "available" : "not available"))
                console.log("Messages are " + (tray.supportsMessages ? "supported" : "not supported"))
                tray.showMessage("You received 31 BTC", "Click here to hear more lies.", 1)
            }
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
