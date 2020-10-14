import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import "../Wallet"
import "../Exchange"
import "../Sidebar"

SetupPage {
    // Override
    property var onLoaded: () => {}

    readonly property string current_status: API.app.initial_loading_status

    onCurrent_statusChanged: {
        if(current_status === "complete")
            onLoaded()
    }


    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"

    content: ColumnLayout {
        DefaultText {
            text_value: qsTr("Loading, please wait")
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
                text_value: (current_status === "initializing_mm2" ? qsTr("Initializing MM2") :
                             current_status === "enabling_coins" ? qsTr("Enabling assets") : qsTr("Getting ready")) + "..."
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
