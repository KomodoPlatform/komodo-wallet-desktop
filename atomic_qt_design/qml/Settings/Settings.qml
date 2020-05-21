import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Item {
    function disconnect() {
        API.get().disconnect()
        onDisconnect()
    }

    function reset() {

    }

    function onOpened() {
        if(mm2_version === '') mm2_version = API.get().get_mm2_version()
    }

    property string mm2_version: ''
    property var fiats: (["USD", "EUR"])

    ColumnLayout {
        anchors.centerIn: parent
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Style.textSize2
            text: API.get().empty_string + (qsTr("Settings"))
        }

        Rectangle {
            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius

            Layout.alignment: Qt.AlignHCenter

            width: 400
            height: layout.childrenRect.height + layout.anchors.topMargin * 2

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.top: parent.top
                anchors.topMargin: anchors.leftMargin
                id: layout

                ComboBoxWithTitle {
                    id: combo_fiat
                    title: API.get().empty_string + (qsTr("Fiat"))
                    Layout.fillWidth: true

                    field.model: fiats
                    field.onCurrentIndexChanged: {
                        API.get().fiat = fiats[field.currentIndex]
                    }
                    Component.onCompleted: {
                        field.currentIndex = fiats.indexOf(API.get().fiat)
                    }
                }

                Languages {
                    Layout.alignment: Qt.AlignHCenter
                }

                HorizontalLine {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                }

                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Open Logs Folder"))
                    onClicked: {
                        API.get().export_swaps_json()
                        const prefix = Qt.platform.os == "windows" ? "file:///" : "file://"
                        Qt.openUrlExternally(prefix + API.get().get_log_folder())
                    }
                }

                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("View Seed"))
                    onClicked: recover_seed_modal.open()
                }

                RecoverSeedModal {
                    id: recover_seed_modal
                }

                HorizontalLine {
                    Layout.fillWidth: true
                }

                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Disclaimer and ToS"))
                    onClicked: eula.open()
                }

                EulaModal {
                    id: eula
                    close_only: true
                }

                HorizontalLine {
                    Layout.fillWidth: true
                }

                DangerButton {
                    text: API.get().empty_string + (qsTr("Delete Wallet"))
                    Layout.fillWidth: true
                    onClicked: delete_wallet_modal.open()
                }

                DeleteWalletModal {
                    id: delete_wallet_modal
                }

                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Log out"))
                    onClicked: disconnect()
                }
            }
        }
    }

    DefaultText {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: anchors.bottomMargin
        text: API.get().empty_string + (qsTr("mm2 version") + ":    " + mm2_version)
        font.pixelSize: Style.textSizeSmall
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
