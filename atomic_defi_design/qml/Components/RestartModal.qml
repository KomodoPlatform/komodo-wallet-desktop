import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"
import ".."

BasicModal {
    id: root

    closePolicy: Popup.NoAutoClose

    onOpened: restart_timer.restart()

    readonly property double total_time: 5
    property double time_left: total_time
    Timer {
        id: restart_timer
        interval: 100
        repeat: true
        onTriggered: time_left -= interval / 1000
    }

    onTime_leftChanged: {
        if(time_left <= 0) {
            time_left = 0
            API.app.restart()
        }
    }


    ModalContent {
        title: API.app.settings_pg.empty_string + (qsTr("Applying the changes") + "...")

        DefaultText {
            text_value: API.app.settings_pg.empty_string + (qsTr("Restarting the application..."))

            Layout.alignment: Qt.AlignHCenter
        }

        DefaultBusyIndicator {
            Layout.alignment: Qt.AlignHCenter
        }

        DefaultText {
            text_value: API.app.settings_pg.empty_string + (General.formatDouble(time_left, 1, true))

            Layout.alignment: Qt.AlignHCenter
        }
    }
}
