import QtQuick 2.12

import "Components" as Dex
import "Constants" as Dex

Dex.MultipageModal
{
    id: root

    Dex.MultipageModalContent
    {
        titleText: qsTr("New Update")
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
