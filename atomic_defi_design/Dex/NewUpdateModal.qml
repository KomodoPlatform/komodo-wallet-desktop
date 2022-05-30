import QtQuick 2.12
import QtQuick.Layouts 1.12

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

    Dex.MultipageModalContent
    {
        titleText: qsTr("Searching new updates")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DefaultText
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
            Dex.DefaultButton
            {
                text: qsTr("Close")
                onClicked: close()
            }
        ]
    }

    Dex.MultipageModalContent
    {
        titleText: qsTr("Searching new updates")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DefaultText
        {
            text: qsTr("Could not check new updates because of the following reason: \n%1").arg(Dex.API.app.updateCheckerService.updateInfo.status)
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
            {
                text: qsTr("Close")
                onClicked: close()
            }
        ]
    }

    Dex.MultipageModalContent
    {
        titleText: qsTr("New version found")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DefaultText
        {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("%1 %2 is available !").arg(Dex.API.app_name).arg(Dex.API.app.updateCheckerService.updateInfo.newVersion)
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
            {
                text: qsTr("Download")
                onClicked: { Qt.openUrlExternally(Dex.API.app.updateCheckerService.updateInfo.downloadUrl); close() }
            },
            Dex.DefaultButton
            {
                text: qsTr("Close")
                onClicked: close()
            }
        ]
    }

    Dex.MultipageModalContent
    {
        titleText: qsTr("Searching new updates")
        titleAlignment: Qt.AlignHCenter
        spacing: 16

        Dex.DefaultText
        {
            text: qsTr("Your application is updated.")
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            Dex.DefaultButton
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
            if (Dex.API.app.updateCheckerService.updateInfo)
            {
                root.open()
            }
        }
    }
}
