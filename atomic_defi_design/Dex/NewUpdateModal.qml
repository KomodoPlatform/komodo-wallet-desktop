import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.15               //> Qt.exit
import QtQuick.Controls 2.15    //> Popup.NoAutoClose

import "Components" as Dex
import "Constants" as Dex

Dex.MultipageModal
{
    id: root

    currentIndex:
    {
        if (Dex.API.app.updateCheckerService.isFetching)
            return 0
        else if (Dex.API.app.updateCheckerService.updateInfo.rpcCode !== 200)
            return 1
        else if (Dex.API.app.updateCheckerService.updateInfo.updateNeeded)
            return 2
        return 3
    }

    Component.onCompleted:
    {
        if (Dex.API.app.updateCheckerService.updateInfo)
        {
            console.log("init updateInfo.status: " + Dex.API.app.updateCheckerService.updateInfo.status)
            console.log("init updateInfo.updateNeeded: " + Dex.API.app.updateCheckerService.updateInfo.updateNeeded)
            console.log("init updateInfo.newVersion: " + Dex.API.app.updateCheckerService.updateInfo.newVersion)
            console.log("init updateInfo.downloadUrl: " + Dex.API.app.updateCheckerService.updateInfo.downloadUrl)
            console.log("init updateInfo.changelog: " + Dex.API.app.updateCheckerService.updateInfo.changelog)
            if (Dex.API.app.updateCheckerService.updateInfo.updateNeeded == true)
            {
                root.open()
            }
        }
    }

    closePolicy: Popup.NoAutoClose
    
    // Wait for response page
    Dex.MultipageModalContent
    {
        titleText: qsTr("Searching new updates")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DexLabel
        {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Fetching...")
        }

        Dex.DefaultBusyIndicator
        {
            Layout.topMargin: 12
            Layout.alignment: Qt.AlignHCenter
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.CancelButton
            {
                text: qsTr("Close")
                onClicked: close()
            }
        ]
    }

    // Failed to fetch page
    Dex.MultipageModalContent
    {
        titleText: qsTr("Searching new updates")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DexLabel
        {
            text: qsTr("Could not check new updates for the following reason: \n%1").arg(Dex.API.app.updateCheckerService.updateInfo.status)
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.CancelButton
            {
                text: qsTr("Close")
                onClicked: close()
            }
        ]
    }

    // Response page
    Dex.MultipageModalContent
    {
        titleText: Dex.API.app.updateCheckerService.updateInfo.status === "required" 
            ? qsTr("Mandatory version found")
            : qsTr("New version found")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DexLabel
        {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("%1 %2 is available !").arg(Dex.API.app_name).arg(Dex.API.app.updateCheckerService.updateInfo.newVersion)
        }

        Dex.DexLabel
        {
            visible: Dex.API.app.updateCheckerService.updateInfo.status === "required"
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("This update is mandatory to continue using the application")
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
            {
                Layout.preferredWidth: 120
                text: qsTr("Download")
                onClicked: { Qt.openUrlExternally(Dex.API.app.updateCheckerService.updateInfo.downloadUrl); if (Dex.API.app.updateCheckerService.updateInfo.status !== "required") close() }
            },
            Dex.DefaultButton
            {
                Layout.preferredWidth: 120
                text: Dex.API.app.updateCheckerService.updateInfo.status === "required" ? qsTr("Close Dex") : qsTr("Close")
                onClicked: Dex.API.app.updateCheckerService.updateInfo.status === "required" ? Qt.exit(0) : close()
            }
        ]
    }

    Dex.MultipageModalContent
    {
        titleText: qsTr("Searching new updates")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DexLabel
        {
            text: qsTr("Your application is up to date!")
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.CancelButton
            {
                text: qsTr("Close")
                onClicked: close()
            }
        ]
    }

    Connections
    {
        target: Dex.API.app.updateCheckerService

        function onUpdateInfoChanged()
        {
            console.log("updateInfo.status: " + Dex.API.app.updateCheckerService.updateInfo.status)
            console.log("updateInfo.updateNeeded: " + Dex.API.app.updateCheckerService.updateInfo.updateNeeded)
            console.log("updateInfo.newVersion: " + Dex.API.app.updateCheckerService.updateInfo.newVersion)
            console.log("updateInfo.downloadUrl: " + Dex.API.app.updateCheckerService.updateInfo.downloadUrl)
            console.log("updateInfo.changelog: " + Dex.API.app.updateCheckerService.updateInfo.changelog)
            if (Dex.API.app.updateCheckerService.updateInfo)
            {
                if (Dex.API.app.updateCheckerService.updateInfo.updateNeeded == true)
                {
                    root.open()
                }
            }
        }
    }
}
