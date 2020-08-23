import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    width: 1100

    onClosed: {
        input_password.reset()
    }

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().settings_pg.empty_string + (qsTr("Set Camouflage Password"))
        }

        FloatingBackground {
            id: warning_bg
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            width: parent.width - 5
            height: warning_texts.height + 20

            Column {
                id: warning_texts
                anchors.centerIn: parent
                width: parent.width
                spacing: 10

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: API.get().settings_pg.empty_string + (qsTr("Camouflage password is a second secret wallet password"))
                    font.pixelSize: Style.textSize2
                }

                DefaultText {
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text_value: API.get().settings_pg.empty_string + (qsTr("Balance lower than actual will be displayed on login with it"))
                }
            }
        }

        PasswordForm {
            id: input_password
            Layout.fillWidth: true
            field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter a new protection password"))
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Save"))
                Layout.fillWidth: true
                enabled: input_password.isValid()
                onClicked: {
                    console.log("Setting camouflage password...")
//                    if(API.get().set_camouflage_password(input_password.field.text)) {
//                        root.close()
//                    }
                }
            }
        }
    }
}
