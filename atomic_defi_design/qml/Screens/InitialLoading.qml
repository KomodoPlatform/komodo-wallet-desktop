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

    readonly property string current_status: API.app.wallet_mgr.initial_loading_status

    onCurrent_statusChanged: {
        if(current_status === "complete")
            onLoaded()
    }

    image_path: "file:///"+ atomic_logo_path +  "/"+ theme.bigSidebarLogo
    image_margin: 30
    backgroundColor: 'transparent'
    borderColor: 'transparent'
    content: ColumnLayout {

        DefaultBusyIndicator {
            Layout.preferredHeight: 100
            Layout.preferredWidth: 100 
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: -15
            Layout.rightMargin: Layout.leftMargin*0.75
            scale: 0.8
        }

        DefaultText {
            text_value: qsTr("Loading, please wait")
            Layout.bottomMargin: 10
        }

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: (current_status === "initializing_mm2" ? qsTr("Initializing MM2") :
                         current_status === "enabling_coins" ? qsTr("Enabling assets") : qsTr("Getting ready")) + "..."
        }
    }
}
