import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt.labs.platform 1.0

import "../Constants"
import "../Components"

FloatingBackground {
    id: root

    function reset() {
        visible = false
    }

    function showApp() {
        window.show()
        window.raise()
        window.requestActivate()
    }

    visible: false

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        hoverEnabled: true
    }

    // Events
    function onSwapStatusUpdated(old_swap_status, new_swap_status, swap_uuid) {
        displayMessage(qsTr("Swap status updated"), old_swap_status + " " + General.right_arrow_icon + " " + new_swap_status)
    }


    // System
    Component.onCompleted: {
        API.get().notification_mgr.updateSwapStatus.connect(onSwapStatusUpdated)
    }

    function displayMessage(title, message) {
        tray.showMessage(title, message)
    }

    SystemTrayIcon {
        id: tray
        visible: true
        iconSource: General.coinIcon("KMD")
        onMessageClicked: {
            root.visible = true
            showApp()
        }

        tooltip: qsTr("AtomicDEX Pro")

        onActivated: showApp()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        DefaultText {
            text_value: API.get().empty_string + (qsTr("Notifications"))
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.pixelSize: Style.textSize2
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
                //displayMessage("You received 31 BTC", "Click here to hear more lies.")
                onSwapStatusUpdated("Ongoing", "Finished", "123456")
            }
        }

        DefaultButton {
            text: API.get().empty_string + (qsTr("Close"))
            Layout.alignment: Qt.AlignRight
            onClicked: root.visible = false
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
