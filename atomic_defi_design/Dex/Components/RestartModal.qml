//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! Project Imports
import "../Constants"
import App 1.0

MultipageModal
{
    id: root

    property double durationBeforeRestart: 5            // Duration in seconds before the modal restarts the application.
    property string reasonMsg: ""                       // A reason message to display to the user.
    property var    onTimerEnded: () => {}              // A callback to call when the modal is about to restart the application.

    property double _timeLeft: durationBeforeRestart    // Stores the current time left. It is calculated by `_restartTimer` object.

    function restartNow() { _timeLeft = 0 }             // Do not wait and restarts the application immediately.

    closePolicy: Popup.NoAutoClose                      // Disallows modal closing.

    onOpened: _restartTimer.restart()
    on_TimeLeftChanged:
    {
        if (_timeLeft <= 0)
        {
            console.log("Restarting the application...")
            _restartTimer.stop()
            onTimerEnded()
            API.app.restart()
        }
    }

    MultipageModalContent
    {
        Layout.fillWidth: true
        titleText: qsTr("Applying the changes...")

        Timer
        {
            id: _restartTimer

            interval: 100
            repeat: true

            onTriggered: _timeLeft -= interval / 1000   // Calculates time left.
        }

        DexLabel
        {
            //! Positioning.
            Layout.alignment: Qt.AlignHCenter

            text_value: reasonMsg !== "" ? qsTr("Restarting the application. %1").arg(reasonMsg) : qsTr("Restarting the application...")
        }

        DefaultBusyIndicator { Layout.alignment: Qt.AlignHCenter }

        DexLabel
        {
            Layout.alignment: Qt.AlignHCenter
            text_value: General.formatDouble(_timeLeft, 1, true)
            font: atomic_fixed_font
        }
    }
}
