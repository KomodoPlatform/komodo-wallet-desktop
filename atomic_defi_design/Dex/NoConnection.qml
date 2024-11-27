import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "Screens"
import "Constants"
import "Components"

Rectangle {
    id: app
    color: Style.colorTheme8

    ColumnLayout {
        spacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        DexLabel {
            text_value: qsTr("No connection")
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Style.textSize3
        }

        DexLabel {
            text_value: qsTr("Please make sure you are connected to the internet")
            Layout.alignment: Qt.AlignHCenter
        }


        DexLabel {
            text_value: qsTr("Will automatically retry in %1 seconds").arg(General.formatDouble(API.app.internet_checker.seconds_left_to_auto_retry, 0))
            Layout.alignment: Qt.AlignHCenter
        }

        DefaultBusyIndicator {
            Layout.alignment: Qt.AlignHCenter
        }

        DefaultButton {
            text: qsTr("Retry")
            onClicked: API.app.internet_checker.retry()
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
