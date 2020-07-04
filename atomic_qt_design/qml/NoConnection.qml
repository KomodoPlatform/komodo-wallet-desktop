import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "Screens"
import "Constants"
import "Components"

Rectangle {
    id: app
    visible: !connected
    color: Style.colorTheme8

    // Check Internet Connection
    property bool connected: true
    property bool current_connection: true

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var doc = new XMLHttpRequest();
            doc.onreadystatechange = function() {
                if(doc.readyState === 1) {
                    if(!current_connection) connected = false
                    current_connection = false
                }
                if(doc.readyState === 3) current_connection = true
                if(doc.readyState === 4) connected = current_connection
            }

            doc.open("GET", "http://google.com")
            doc.send()
        }
    }

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
