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

    readonly property string current_status: API.get().initial_loading_status
    readonly property bool loaded_all_coins: API.get().portfolio_pg.portfolio_mdl.length >= API.get().enabled_coins.length

    property Timer check_loading_complete: Timer {
        interval: 64
        repeat: true
        onTriggered: {
            if(current_status === "complete" && loaded_all_coins) {
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
                text_value: API.get().settings_pg.empty_string + ((current_status === "initializing_mm2" ? qsTr("Initializing MM2") :
                       current_status === "enabling_coins" ? qsTr("Enabling coins") :
                       current_status === "complete" && loaded_all_coins ? qsTr("Complete") : qsTr("Getting ready")) + "...")
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
