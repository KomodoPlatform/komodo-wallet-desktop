import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "Screens"
import "Constants"
import "Components"

Rectangle {
    id: app
    visible: !API.get().internet_checker.internet_reacheable
    color: Style.colorTheme8

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        DefaultText {
            text_value: API.get().empty_string + (qsTr("No connection"))
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Style.textSize3
        }

        DefaultBusyIndicator {
            Layout.alignment: Qt.AlignHCenter
        }

        DefaultText {
            text_value: API.get().empty_string + (qsTr("Please make sure you are connected to the internet"))
            Layout.alignment: Qt.AlignHCenter
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
