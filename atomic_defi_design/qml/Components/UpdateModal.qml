import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"

BasicModal {
    id: root

    readonly property bool required_update: update_needed && (API.app.update_checker.update_status.status === "required")
    readonly property bool suggest_update: update_needed && (required_update || API.app.update_checker.update_status.status === "recommended")

    readonly property string update_title: !update_needed ? qsTr("Changelog") : (qsTr("New Update!") + " " + (API.app.update_checker.update_status.current_version + "  " + General.right_arrow_icon + "  " + API.app.update_checker.update_status.new_version))
    readonly property string update_state: !update_needed ? qsTr("Up to date") : !suggest_update ? qsTr("Available") : required_update ? qsTr("Required") : qsTr("Recommended")
    readonly property string update_color: !update_needed || !suggest_update ? Style.colorGreen : required_update ? Style.colorRed : Style.colorOrange

    onSuggest_updateChanged: {
        if(suggest_update) {
            // Force-open if update is suggested
            if(!root.opened) root.open()
        }
    }

    closePolicy: suggest_update ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)

    ModalContent {
        title: `${General.download_icon} &nbscp;&nbscp; ${root.update_title} <font color="${root.update_color}">(${root.update_state})</font>`

        DefaultTextArea {
            id: text_area
            Layout.fillWidth: true
            readOnly: true
            text: status_good ? API.app.update_checker.update_status.changelog : (qsTr("Problem occured") + ": " + API.app.update_checker.update_status.status)
            textFormat: Text.MarkdownText
            remove_newline: false
        }

        footer: [
            DefaultButton {
                Layout.fillWidth: true
                text: update_needed ? qsTr("Skip") : qsTr("Close")
                onClicked: root.close()
                visible: !required_update
            },

            PrimaryButton {
                Layout.fillWidth: true
                visible: update_needed
                enabled: status_good
                text: qsTr("Download")
                onClicked: Qt.openUrlExternally(API.app.update_checker.update_status.download_url)
            }
        ]
    }
}
