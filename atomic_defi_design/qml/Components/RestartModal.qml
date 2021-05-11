import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"

BasicModal
{
    id: root

    closePolicy: Popup.NoAutoClose

    onOpened: restart_timer.restart()

    readonly property double total_time: 5
    property double time_left: total_time
    property bool restart_requested: false
    property var task_before_restart: () => {}
    property string reason: ""
    Timer
    {
        id: restart_timer
        interval: 100
        repeat: true
        onTriggered: time_left -= interval / 1000
    }

    onTime_leftChanged:
    {
        if (time_left <= 0 && !restart_requested)
        {
            console.log("Restarting the application...")
            restart_timer.stop()
            restart_requested = true
            time_left = 0
            task_before_restart()
            API.app.restart()
        }
    }


    ModalContent
    {
        title: qsTr("Applying the changes...")

        DefaultText
        {
            text_value: reason !== "" ? qsTr("Restarting the applications. %1").arg(reason) : qsTr("Restarting the application...")
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
        }

        DefaultBusyIndicator { Layout.alignment: Qt.AlignHCenter }

        DefaultText
        {
            text_value: General.formatDouble(time_left, 1, true)
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
