import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"
import "../Wallet"
import "../Exchange"
import "../Sidebar"

SetupPage {
    // Override
    function onLoaded() {}

    property Timer check_loading_complete: Timer {
        interval: 64
        repeat: true
        onTriggered: {
            if(API.get().initial_loading_status === "complete") {
                running = false
                onLoaded()
            }
        }
    }

    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"
    title: qsTr("Loading, please wait")
    content: RowLayout {
        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: -15
            Layout.rightMargin: Layout.leftMargin
            scale: 0.5
        }

        DefaultText {
            // TODO: Remove these if statements, localization will take care of that
            text: qsTr(API.get().initial_loading_status === "initializing_mm2" ? "Initializing MM2" :
                       API.get().initial_loading_status === "enabling_coins" ? "Enabling coins" :
                       API.get().initial_loading_status === "complete" ? "Complete" : "") + "..."
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
