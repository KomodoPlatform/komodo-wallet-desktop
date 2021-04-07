// Qt imports
import QtQml 2.15            //> Component
import QtQuick.Layouts 1.15  //> Layout.fillWidth
import QtQuick.Controls 2.15 //> ProgressBar

// Project imports
import "../Components" //> BasicModal
import "../Constants"  //> API.app.self_update_service

BasicModal
{
    id: root

    readonly property var    self_update_service:      API.app.self_update_service
    readonly property string last_release_tag_name:    self_update_service.last_release_tag_name
    readonly property bool   update_needed:            self_update_service.update_needed
    readonly property bool   update_downloading:       self_update_service.update_downloading
    readonly property real   update_download_progress: self_update_service.update_download_progress
    readonly property bool   update_ready:             self_update_service.update_ready

    onUpdate_neededChanged:
    {
        if (update_needed)
        {
            currentIndex = 0
            visible = true
        }
    }

    onUpdate_downloadingChanged:
    {
        if (update_downloading)
        {
            currentIndex = 1
            visible = true
        }
    }

    onUpdate_readyChanged:
    {
        if (update_ready)
        {
            currentIndex = 2
            visible = true
        }
    }

    Component.onCompleted: self_update_service.fetch_last_release_info()

    visible: false

    // First section. Asks user to update its client.
    ModalContent
    {
        title: qsTr("New update detected !")

        DefaultText
        {
            Layout.fillWidth: true

            text: qsTr("Do you want to update %1 from %2 to %3 ?")
                    .arg(API.app_name).arg(API.current_version).arg(last_release_tag_name)
        }

        footer:
        [
            PrimaryButton
            {
                text: qsTr("Download")

                onClicked: self_update_service.download_update()
            },
            DefaultButton
            {
                text: qsTr("Remind me later")

                onClicked: root.visible = false
            }
        ]
    }

    // Progress bar
    ModalContent
    {
        title: qsTr("Download in progress...")

        RowLayout
        {
            Layout.fillWidth: true

            ProgressBar
            {
                Layout.fillWidth: true
                value: update_download_progress
            }

            DefaultText
            {
                Layout.preferredWidth: 40
                text: "%1 %".arg(Math.round(update_download_progress * 100))
            }
        }
    }

    ModalContent
    {
        title: qsTr("Update is ready !")

        footer:
        [
            PrimaryButton
            {
                text: qsTr("Restart now")

                onClicked:
                {
                    self_update_service.perform_update()
                    root.visible = false
                }
            },
            DefaultButton
            {
                text: qsTr("Restart later")

                onClicked: close()
            }
        ]
    }
}
