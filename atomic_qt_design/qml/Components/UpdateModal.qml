import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

DefaultModal {
    readonly property bool status_good: API.get().update_status.rpc_code === 200

    id: root

    padding: 50

    width: 900
    height: Math.min(text_area.height + padding*2, 700)

    ColumnLayout {
        anchors.fill: parent

        ModalHeader {
            title: API.get().empty_string + (General.download_icon + "   " + qsTr("New Update!") + " " + (API.get().update_status.current_version + "  " + General.right_arrow_icon + "  " + API.get().update_status.new_version))
        }

        DefaultFlickable {
            Layout.fillWidth: true
            Layout.fillHeight: true

            contentWidth: text_area.width
            contentHeight: text_area.height

            DefaultTextArea {
                id: text_area
                width: root.width - root.padding*2
                readOnly: true
                text: status_good ? API.get().update_status.changelog : (qsTr("Problem occured") + ": " + API.get().update_status.status)
                textFormat: Text.MarkdownText
                remove_newline: false
            }
        }

        PrimaryButton {
            Layout.topMargin: root.padding * 0.5
            Layout.alignment: Qt.AlignHCenter
            enabled: status_good
            text: API.get().empty_string + (qsTr("Download"))
            onClicked: Qt.openUrlExternally(API.get().update_status.download_url)
        }
    }
}
