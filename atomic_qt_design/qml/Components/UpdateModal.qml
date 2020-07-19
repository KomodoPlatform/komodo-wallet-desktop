import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

DefaultModal {
    readonly property bool status_good: API.get().update_status.rpc_code !== 200

    id: root

    padding: 50

    width: 900
    height: Math.min(text_area.height + padding*2, 700)

    Component.onCompleted: {
        console.log("Update Status: " + JSON.stringify(API.get().update_status))
    }

    ColumnLayout {
        anchors.fill: parent

        ModalHeader {
            title: API.get().empty_string + (General.download_icon + " " + qsTr("New Update!") + " " + qsTr("Version:") + " " + API.get().update_status.new_version)
        }

        DefaultFlickable {
            contentWidth: text_area.width
            contentHeight: text_area.height

            TextAreaWithTitle {
                id: text_area
                title: API.get().empty_string + (qsTr("Change-log"))
                width: root.width - root.padding*2
                field.readOnly: true
                field.text: status_good ? API.get().update_status.changelog : (qsTr("Problem occured") + ": " + API.get().update_status.status)
                field.textFormat: Text.MarkdownText
                copyable: true
                remove_newline: false
            }
        }

        DefaultButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: root.padding
            enabled: status_good
            text: API.get().empty_string + (qsTr("Download"))
            onClicked: Qt.openUrlExternally(API.get().update_status.download_url)
        }
    }
}
