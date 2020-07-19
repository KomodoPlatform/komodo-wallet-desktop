import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

DefaultModal {
    readonly property bool status_good: API.get().update_status.rpc_code === 200
    readonly property bool update_needed: API.get().update_status.update_needed
    readonly property bool required_update: update_needed && (API.get().update_status.status === "required")
    readonly property bool suggest_update: update_needed && (required_update || API.get().update_status.status === "recommended")

    onSuggest_updateChanged: {
        if(suggest_update) {
            // Force-open if update is suggested
            if(!root.opened && status_good) root.open()
        }
    }

    id: root

    padding: 50

    closePolicy: suggest_update ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)

    width: 900
    height: Math.min(text_area.height + padding*2, 700)

    DefaultText {
        anchors.top: parent.top
        anchors.topMargin: padding
        anchors.right: parent.right
        anchors.rightMargin: padding

        font.pixelSize: Style.textSize2

        text_value: API.get().empty_string + ("(" + (!suggest_update ? qsTr("Available") : required_update ? qsTr("Required") : qsTr("Recommended")) + ")")
        color: !suggest_update ? Style.colorGreen : required_update ? Style.colorRed : Style.colorOrange
    }

    ColumnLayout {
        anchors.fill: parent

        ModalHeader {
            id: header
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

        RowLayout {
            Layout.topMargin: root.padding * 0.5
            Layout.alignment: Qt.AlignHCenter

            DefaultButton {
                text: API.get().empty_string + (qsTr("Skip"))
                onClicked: root.close()
                visible: !required_update
            }

            PrimaryButton {
                enabled: status_good
                text: API.get().empty_string + (qsTr("Download"))
                onClicked: Qt.openUrlExternally(API.get().update_status.download_url)
            }
        }
    }
}
