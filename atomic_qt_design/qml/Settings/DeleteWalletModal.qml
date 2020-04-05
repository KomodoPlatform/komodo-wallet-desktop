import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

    width: 800

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("Delete Wallet"))
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            color: Style.colorRed2
            radius: 10

            width: parent.width - 5
            height: warning_texts.height + 20

            ColumnLayout {
                id: warning_texts
                anchors.centerIn: parent

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text: API.get().empty_string + (qsTr("Are you sure you want to delete %1 wallet?", "WALLET_NAME").arg(API.get().wallet_default_name))
                    font.pixelSize: Style.textSize2
                }

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text: API.get().empty_string + (qsTr("If so, make sure you record your seed phrase in order to restore your wallet in future."))
                }
            }
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            DangerButton {
                text: API.get().empty_string + (qsTr("Delete"))
                Layout.fillWidth: true
                onClicked: {
                    root.close()

                    API.get().delete_wallet(API.get().wallet_default_name)
                    disconnect()
                }
            }
        }
    }
}
