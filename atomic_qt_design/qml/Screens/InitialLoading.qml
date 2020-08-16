import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"
import "../Wallet"
import "../Exchange"
import "../Sidebar"

SetupPage {
    // Override
    property var onLoaded: () => {}

    property Timer check_loading_complete: Timer {
        interval: 64
        repeat: true
        onTriggered: {
            if(API.get().initial_loading_status === "complete" && API.get().portfolio_mdl.length >= 2) {
                running = false
                onLoaded()
            }
        }
    }

    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"

    content: ColumnLayout {
        DefaultText {
            text_value: API.get().settings_pg.empty_string + (qsTr("Loading, please wait"))
            Layout.bottomMargin: 10
        }

        RowLayout {
            DefaultBusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: -15
                Layout.rightMargin: Layout.leftMargin*0.75
                scale: 0.5
            }

            DefaultText {
                text_value: API.get().settings_pg.empty_string + ((API.get().initial_loading_status === "initializing_mm2" ? qsTr("Initializing MM2") :
                       API.get().initial_loading_status === "enabling_coins" ? qsTr("Enabling coins") :
                       API.get().initial_loading_status === "complete" && API.get().portfolio_mdl.length >= 2 ? qsTr("Complete") : qsTr("Getting ready")) + "...")
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
